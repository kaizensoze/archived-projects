# -*- coding: utf-8 -*-

# Command line args:
#   python find_via_google_places.py [input.csv] [city]

import requests
import csv
import sys
from urllib import urlencode


def read_csv():
    ret = []
    with open(sys.argv[1], 'r') as csvfile:
        spamreader = csv.reader(csvfile)
        for row in spamreader:
            ret.append(' - '.join(filter(bool, row)))
    return ret

restaurants = read_csv()


def pull_google_places(r):
    API_KEY = 'AIzaSyArn_tALrEJEaUoITff5mX1hcFtNAv14DY'
    TEXT_SEARCH = (
        "https://maps.googleapis.com/maps/api/place/textsearch/"
        "json?{parameters}"
    )
    DETAILS_SEARCH = (
        "https://maps.googleapis.com/maps/api/place/details/"
        "json?{parameters}"
    )

    text_search_formatted = TEXT_SEARCH.format(parameters=urlencode({
        'sensor': 'false',
        'key': API_KEY,
        'query': r + ", {city}".format(city=sys.argv[2])
    }))

    response = requests.get(text_search_formatted)

    if response.status_code == 200:
        rjson = response.json()
        for result in rjson['results']:
            reference = result['reference']
            details_search_formatted = DETAILS_SEARCH.format(
                parameters=urlencode({
                    'sensor': 'false',
                    'key': API_KEY,
                    'reference': reference
                })
            )
            final_response = requests.get(details_search_formatted)
            ret = final_response.json().get('result')
            if ret is not None:
                yield ret
            else:
                print >> sys.stderr, final_response.json()


def get_address_component(result, type_):
    try:
        return filter(
            lambda x: type_ in x['types'],
            result['address_components']
        )[0]['long_name']
    except IndexError:
        return ''
    except KeyError:
        return ''


def parse_result_to_csv(result):
    restaurant_name = result.get('name', '')
    website_url = result.get('website', '')
    price_point = unicode(result.get('price_level', ''))
    hours = unicode(result.get('opening_hours', {}).get('periods', []))
    lat = unicode(result.get('geometry', {}).get('location', {}).get(
        'lat',
        ''
    ))
    lng = unicode(result.get('geometry', {}).get('location', {}).get(
        'lng',
        ''
    ))
    phone_number = result.get('phone_number', '')
    address = u"{number} {street}".format(
        number=get_address_component(result, 'street_number'),
        street=get_address_component(result, 'route')
    )
    city = get_address_component(result, 'locality')
    state = get_address_component(result, 'administrative_area_level_1')
    zipcode = get_address_component(result, 'postal_code')

    return map(lambda x: x.encode('utf-8'), [
        restaurant_name,
        phone_number,
        website_url,
        price_point,
        lat,
        lng,
        address,
        city,
        state,
        zipcode,
        hours
    ])


with open('out.csv', 'w') as f:
    restaurant_writer = csv.writer(f)
    for r in restaurants:
        print r
        for result in pull_google_places(r):
            restaurant_writer.writerow(parse_result_to_csv(result))
