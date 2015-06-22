import re
import xml.sax
from django.conf import settings
import requests
from taste.apps.restaurants.models import Location, Occasion


class VendorLocation(object):
    def __init__(self):
        self.direct_url = None
        self.mobile_url = None
        self.phone_number = None


class SeamlessParser(xml.sax.ContentHandler):
    def __init__(self, *args, **kwargs):
        # This isn't a new-style class, as it doesn't inherit from one. So no
        # super for us.
        xml.sax.ContentHandler.__init__(self, *args, **kwargs)
        self.vendor_location = None
        self.in_market = False
        self.in_direct_url = False
        self.in_mobile_url = False
        self.in_phone_number = False
        self.locations = []

    def startElement(self, name, attrs):
        if name == 'VendorLocation':
            self.vendor_location = VendorLocation()
        if self.vendor_location is not None:
            if name == 'MarketName':
                self.in_market = True
            else:
                self.in_market = False
            if name == 'DirectUrl':
                self.in_direct_url = True
            else:
                self.in_direct_url = False
            if name == 'MobileUrl':
                self.in_mobile_url = True
            else:
                self.in_mobile_url = False
            if name == 'Vendor_PhoneNumber':
                self.in_phone_number = True
            else:
                self.in_phone_number = False

    def endElement(self, name):
        if name == 'VendorLocation':
            if self.vendor_location is not None:
                self.locations.append(self.vendor_location)

    def characters(self, content):
        if self.in_direct_url:
            self.vendor_location.direct_url = content
        if self.in_mobile_url:
            self.vendor_location.mobile_url = content
        if self.in_phone_number:
            self.vendor_location.phone_number = content


def give_url_tracking_info(url):
    """
    The URLs from Seamless have a placeholder 0 at the end, which we replace
    with our SEAMLESS_PARTNER_ID.
    They also need our SEAMLESS_XML_TRACKING appended.
    """
    return url[:-1] + settings.SEAMLESS_PARTNER_ID\
        + settings.SEAMLESS_XML_TRACKING


def normalize_phone(phone):
    """
    Normalizes a phone number for search against a
    django.contrib.localflavor.us.models.PhoneNumberField
    """
    raw_digits = re.sub('[^0-9]', '', phone)
    return "%s-%s-%s" % (raw_digits[0:3], raw_digits[3:6], raw_digits[6:10])


def run_seamless_sync():
    r = requests.get(settings.SEAMLESS_XML_FEED_URL)
    if r.status_code == 200:
        handler = SeamlessParser()
        xml.sax.parseString(r.text.encode('utf-8'), handler)
        delivery = Occasion.objects.get(name='Delivery')
        for location in handler.locations:
            phone = normalize_phone(location.phone_number)
            # Find restaurant location by phone number
            for loc in Location.objects.filter(phone_number=phone):
                # adjust links with settings-derived partner ID
                direct_url = give_url_tracking_info(location.direct_url)
                mobile_url = give_url_tracking_info(location.mobile_url)
                # Set attributes on it
                loc.seamless_direct_url = direct_url
                loc.seamless_mobile_url = mobile_url
                # Save it
                loc.save()
                # Make sure the restaurant has the "Delivery" occasion
                loc.restaurant.occasion.add(delivery)
        # Take everything that wasn't in the XML list anymore...
        phone_numbers = [
            normalize_phone(l.phone_number)
            for l in handler.locations
        ]
        # ... and make sure it doesn't have Seamless URLs.
        Location.objects.exclude(
            seamless_mobile_url='').exclude(
            seamless_direct_url='').exclude(
            phone_number__in=phone_numbers
        ).update(seamless_direct_url='', seamless_mobile_url='')

        # And those with neither Seamless nor Grubhub URLs should not have the
        # Delivery occasion.
        all_delivery_locations = Location.objects.filter(
            seamless_mobile_url='',
            seamless_direct_url='',
            grubhub_url='',
            restaurant__occasion=delivery
        )
        for loc in all_delivery_locations:
            loc.restaurant.occasion.remove(delivery)
    else:
        print "Unexpected response from Seamless: %s" % r.status_code
