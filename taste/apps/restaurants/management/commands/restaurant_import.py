import csv
from multiprocessing import Pool
import geocoder

from django.core.management.base import BaseCommand, CommandError
from optparse import make_option

from taste.apps.restaurants.models import *

days = dict((v,k) for k,v in DAY_CHOICES)
hours = dict((v.replace(' ', ''),k) for k,v in HOUR_CHOICES)

def process_restaurant(restaurant):
    r = Restaurant()

    print restaurant['name']

    r.name = restaurant['name']
    r.url = restaurant['url']
    r.opentable = restaurant['opentable']
    r.menupages = restaurant['menupages']

    try:
        r.price = Price.objects.get(name=restaurant['price'])
    except Price.DoesNotExist:
        pass

    r.save()

    if restaurant['address']:
        geodata = geocoder.encode(restaurant['address'])
        l = Location(restaurant = r, lat = geodata.lat, lng = geodata.lng,
            phone_number = restaurant['phone'], city = geodata.city,
            address = geodata.street_number + ' ' + geodata.street_name + '#' + getattr(geodata, 'number', ''),
            state = geodata.state[1], zip_code = geodata.zip_code)
        l.address = l.address.rstrip('#')
        l.save()

    if restaurant['cuisine1']:
        r.cuisine.add(Cuisine.objects.get(name = restaurant['cuisine1']))
    if restaurant['cuisine2']:
        r.cuisine.add(Cuisine.objects.get(name = restaurant['cuisine2']))
    if restaurant['cuisine3']:
        r.cuisine.add(Cuisine.objects.get(name = restaurant['cuisine3']))
    if restaurant['vegetarian']:
        r.cuisine.add(Cuisine.objects.get(name = 'Vegetarian'))

    for day in days.keys():
        oh = restaurant[day]
        oh = oh.replace(';', ':')
        oh = oh.replace(' ', '')
        oh = oh.lower()
        oh = oh.split(',')
        for hour in oh:
            if hour and 'closed' not in hour and not hour == '24hours':
                hour = hour.split('-')
                if ':' not in hour[0]:
                    length = len(hour[0]) / 2
                    hour[0] = hour[0][:length] + ':00' + hour[0][length:]
                if ':' not in hour[1]:
                    length = len(hour[1]) / 2
                    hour[1] = hour[1][:length] + ':00' + hour[1][length:]
                if 'am' not in hour[0] and 'pm' not in hour[0]:
                    hour[0] = hour[0] + 'pm'
                if 'am' not in hour[1] and 'pm' not in hour[1]:
                    hour[1] = hour[1] + 'pm'
                try:
                    o = OperatingHour.objects.get(day = days[day], open=hours[hour[0]], closed=hours[hour[1]])
                except OperatingHour.DoesNotExist:
                    o = OperatingHour(day = days[day], open=hours[hour[0]], closed=hours[hour[1]])
                    o.save()
                r.hours.add(o)
                r.save()
            if hour == '24hours':
                try:
                    o = OperatingHour.objects.get(day = days[day], open=hours['24Hours'], closed=hours['24Hours'])
                except OperatingHour.DoesNotExist:
                    o = OperatingHour(day = days[day], open=hours['24Hours'], closed=hours['24Hours'])
                    o.save()
                r.hours.add(o)
                r.save()

class Command(BaseCommand):
    help = "Import data from Excel CSV files... run once!"
    option_list = BaseCommand.option_list + (
        make_option('--path', '-p', dest='path', help="Path to CSV"),
    )
    def handle(self, *args, **options):
        if not options['path']:
            raise CommandError('Path Argument Required: --path="/path/to/restaurants.csv"')
        else:
            path = options['path']
            restaurants = csv.DictReader(open(path, 'rb'), dialect='excel')
            restaurants = list(restaurants)

            cuisines = [restaurant['cuisine1'] for restaurant in restaurants]
            cuisines = cuisines + [restaurant['cuisine2'] for restaurant in restaurants]
            cuisines = cuisines + [restaurant['cuisine3'] for restaurant in restaurants]

            cuisines = list(set(cuisines))

            c = Cuisine(name = 'Vegetarian')
            c.save()

            for cuisine in cuisines:
                if cuisine:
                    c = Cuisine(name=cuisine)
                    c.save()

            prices = [restaurant['price'].replace(' ', '') for restaurant in restaurants]
            prices = list(set(prices))

            for price in prices:
                if price:
                    p = Price(name=price)
                    p.save()

            map(process_restaurant, restaurants)
