import json
from base64 import urlsafe_b64encode, urlsafe_b64decode
from datetime import date
from django.db import transaction
from hashlib import sha1
from django.conf import settings
from django.core.exceptions import ImproperlyConfigured

from taste.apps.singleplatform.exceptions import (
    NoRestaurantError,
    NoMenuChangeError
)
from taste.apps.restaurants.models import (
    DAY_CHOICES,
    HOUR_CHOICES,
    OperatingHour
)
from taste.apps.singleplatform.models import Menu, Entry, Price
from urllib import urlencode
import requests
import hmac

BASE_URI = 'http://api.singleplatform.co'
MATCHING_URI = (
    "http://matching-api.singleplatform.com/location-match?client={client_id}"
)
EXCLUDED_MENU_TITLES = (
    'Wine',
    'Drink Menu',
    'Glasses Of Wine - Champagne',
    'Glasses Of Wine - Sherry Wine',
    'Reserve Glasses Of Wine - White Wines',
    'Light Spirited Cocktails',
    'Dark Spirited Cocktails',
)


def get_setting(setting_name):
    ret = getattr(settings, setting_name, None)
    if ret is None:
        raise ImproperlyConfigured(
            'Please provide a value for the setting "%s".' % setting_name
        )
    return ret


def singleplatform_signed_request(path, query, headers=None):
    headers_base = {
        'Accept': 'application/json',
    }
    if headers is not None:
        headers_base.update(headers)
    headers = headers_base
    padding_factor = (
        (4 - len(get_setting('SINGLEPLATFORM_SIGNING_KEY')) % 4) % 4
    )
    key = get_setting('SINGLEPLATFORM_SIGNING_KEY') + ("=" * padding_factor)
    key = urlsafe_b64decode(key)
    query['api'] = get_setting('SINGLEPLATFORM_API_KEY')
    query['client'] = get_setting('SINGLEPLATFORM_CLIENT_ID')
    path_and_query = path + '?' + urlencode(query)
    signed = hmac.new(key, path_and_query, sha1)
    # This is ugly and a little fragile, but the SinglePlatform API cares about
    # the order of query string parameters.
    params = query.items()
    params += [('sig', urlsafe_b64encode(signed.digest()).rstrip('='))]
    r = requests.get(
        BASE_URI + path,
        params=urlencode(params),
        headers=headers)
    return r


def search(query):
    path = '/restaurants/search'
    return singleplatform_signed_request(path, query)


def normalize_phone(phone):
    """
    Not the coolest phone normalizer.
    """
    phone = phone.replace("-", "")\
                 .replace("(", "")\
                 .replace(")", "")\
                 .replace(" ", "")\
                 .lstrip("1")
    if len(phone) != 10 and len(phone) != 0:
        raise ValueError("Invalid phone number.")
    return phone


def find_by_singleplatform_match(restaurant):
    """
    :phone a string representing a phone number.
    :last_modified a string representing the last update to the menu.
    """
    client_id = get_setting('SINGLEPLATFORM_CLIENT_ID')
    query = {
        "matching_criteria": "NAME_PHONE",
        "locations": [
            {
                "name": restaurant.name,
                "phone": normalize_phone(
                    restaurant.locations()[0].phone_number
                ),
            }
        ]
    }
    r = requests.post(
        MATCHING_URI.format(client_id=client_id),
        json.dumps(query)
    )
    if r.status_code == 200:
        return r.json()['response'][0]['spv2id']


def get_hours(restaurant, sp_id):
    if '/' in sp_id:
        raise ValueError(
            "Illegal characters in SinglePlatform restaurant ID: '/'"
        )
    path = '/restaurants/%s' % sp_id
    r = singleplatform_signed_request(path, {})
    ohs = []
    try:
        hours_dict = r.json()['hours']
    except Exception:
        return
    for day, times in hours_dict.items():
        if day == 'holidaySchedule':
            continue
        start = times['start']
        end = times['end']
        # We store day, start, end in weird ways, so here is the mapping:
        days = dict((x[1][:3].lower(), x[0]) for x in DAY_CHOICES)
        day = days[day]
        hours = dict((x[1], x[0]) for x in HOUR_CHOICES)
        try:
            open_ = hours[start]
            closed = hours[end]
        except KeyError:
            continue
        oh = OperatingHour(
            day=day,
            open=open_,
            closed=closed,
        )
        ohs.append(oh)
    print "%s has %s hours" % (sp_id, len(ohs))
    if ohs:
        print "    Clearing %s" % sp_id
        restaurant.hours.clear()
        for oh in ohs:
            oh.save()
            restaurant.hours.add(oh)


# If only MySQL believed in transactions :( -kit
@transaction.commit_on_success
def get_menus(restaurant, sp_id):
    if '/' in sp_id:
        raise ValueError(
            "Illegal characters in SinglePlatform restaurant ID: '/'"
        )
    path = '/restaurants/%s/menu' % sp_id
    old_menu = None
    try:
        menu = Menu.objects.get(restaurant=restaurant)
        if menu.last_modified:
            last_modified = {'If-Modified-Since': menu.last_modified}
        else:
            last_modified = None
        # We can't use transactions with the current production version of
        # MySQL, so we have to hold on to the old menu, and delete it at the
        # end if everything goes well.
        old_menu = menu
    except Menu.DoesNotExist:
        last_modified = None
    r = singleplatform_signed_request(path, {}, last_modified)
    if r.status_code == 404:
        raise NoRestaurantError
    if r.status_code == 304:
        # We raise an error and get out of here.
        raise NoMenuChangeError
    menus = []
    try:
        json_menus = r.json()['menus']
    except Exception:
        return
    for json_menu in json_menus:
        # Exclude wine and beer lists, because they can be long and
        # irrelevant. Sadly, we have to guess based on the title whether it's
        # such a menu.
        if json_menu['title'] in EXCLUDED_MENU_TITLES:
            continue
        now = str(date.today())
        menu = Menu(
            restaurant=restaurant,
            sp_id=json_menu['id'],
            name=json_menu['name'],
            title=json_menu['title'] or '',
            desc=json_menu['desc'] or '',
            footnote=json_menu['footnote'] or '',
            state=True if json_menu['state'] == 'enabled' else False,
            disclaimer=json_menu['disclaimer'] or '',
            attribution_image=json_menu['attributionImage'],
            attribution_image_link=json_menu['attributionImageLink'],
            last_modified=now or ''
        )
        menu.save()
        for json_entry in json_menu['entries']:
            entry = Entry(
                menu=menu,
                sp_id=json_entry['id'],
                type=json_entry['type'],
                order_num=json_entry['orderNum'],
                title=json_entry['title'] or '',
                name=json_entry['name'],
                desc=json_entry['desc'] or '',
                allergens=json_entry.get('allergens') or '',
                allergen_free=json_entry.get('allergenFree') or '',
                restrictions=json_entry.get('restrictions') or '',
                spicy=json_entry.get('spicy') or ''
            )
            entry.save()
            if json_entry['type'] == 'item':
                for json_price in json_entry['prices']:
                    price = Price(
                        entry=entry,
                        order_num=json_price['orderNum'] or 0,
                        title=json_price['title'] or '',
                        price=json_price['price'] or '',
                        unit=json_price['unit'] or '',
                        calories=json_price['calories'] or ''
                    )
                    price.save()
        menus.append(menu)
    if old_menu is not None:
        old_menu.delete()
    return menus
