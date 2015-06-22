import re
import xml.sax
from django.conf import settings
import requests
from taste.apps.restaurants.models import Location, Occasion


class VendorLocation(object):
    def __init__(self):
        self.direct_url_in_progress = []
        self.direct_urls = []
        self.phone_numbers = []

    @property
    def direct_url(self):
        if not self.direct_urls:
            return ''
        if all(map(lambda x: x == self.direct_urls[0], self.direct_urls)):
            return self.direct_urls[0]
        raise ValueError('Varied direct_urls values')

    def add_to_direct_url(self, chunk):
        try:
            self.direct_url_in_progress.append(chunk)
        except AttributeError:
            return

    def finish_direct_url(self):
        try:
            new_url = ''.join(self.direct_url_in_progress)
            self.direct_urls.append(new_url)
        except TypeError:
            pass
        finally:
            self.direct_url_in_progress = []

    def __unicode__(self):
        return str(self.phone_number)

    __str__ = __unicode__


class GrubhubParser(xml.sax.ContentHandler):
    def __init__(self, *args, **kwargs):
        # This isn't a new-style class, as it doesn't inherit from one. So no
        # super for us.
        xml.sax.ContentHandler.__init__(self, *args, **kwargs)
        self.vendor_location = None
        self.in_direct_url = False
        self.in_phone_number = False
        self.locations = []

    def startElement(self, name, attrs):
        if name == 'listing':
            self.vendor_location = VendorLocation()
        if self.vendor_location is not None:
            if name == 'phone':
                self.in_phone_number = True
            if name == 'link':
                self.in_direct_url = True

    def endElement(self, name):
        if self.vendor_location is not None:
            if name == 'listing':
                self.locations.append(self.vendor_location)
                self.vendor_location = None
            if name == 'phone':
                self.in_phone_number = False
            if name == 'link':
                # this overwrites the link with the last instance, keeps being
                # none.
                self.vendor_location.finish_direct_url()
                self.in_direct_url = False

    def characters(self, content):
        if self.vendor_location is not None:
            if self.in_direct_url:
                self.vendor_location.add_to_direct_url(content)
            if self.in_phone_number:
                self.vendor_location.phone_numbers.append(content)


def give_url_tracking_info(url):
    """
    The URLs from Grubhub have a placeholder YOURID, which we replace with our
    GRUBHUB_PARTNER_ID.
    """
    return url.replace('YOURID', settings.GRUBHUB_PARTNER_ID)


def normalize_phone(phones):
    """
    Normalizes a phone number for search against a
    django.contrib.localflavor.us.models.PhoneNumberField
    """
    ret = []
    for phone in phones:
        raw_digits = re.sub('[^0-9]', '', phone)
        ret.append(
            "%s-%s-%s" % (raw_digits[0:3], raw_digits[3:6], raw_digits[6:10])
        )
    return ret


def run_grubhub_sync():
    r = requests.get(settings.GRUBHUB_XML_FEED_URL)
    if r.status_code == 200:
        handler = GrubhubParser()
        xml.sax.parseString(r.text.encode('utf-8'), handler)
        delivery = Occasion.objects.get(name='Delivery')
        for location in handler.locations:
            phones = normalize_phone(location.phone_numbers)
            # Find restaurant location by phone number
            for loc in Location.objects.filter(phone_number__in=phones):
                direct_url = give_url_tracking_info(location.direct_url)
                loc.grubhub_url = direct_url
                loc.save()
                # Make sure the restaurant has the "Delivery" occasion
                loc.restaurant.occasion.add(delivery)
        # Take everything that wasn't in the XML list anymore...
        phone_numbers = []
        for location in handler.locations:
            phone_numbers.extend(normalize_phone(location.phone_numbers))
        # ... and make sure it doesn't have Grubhub URLs.
        Location.objects.exclude(
            grubhub_url='').exclude(
            phone_number__in=phone_numbers
        ).update(grubhub_url='')

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
        print "Unexpected response from Grubhub: %s" % r.status_code
