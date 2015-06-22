import csv
import glob
import os
import re
import sys
import types

from pprint import pprint
from IPython import embed
from datetime import datetime

sys.path.append('/Users/nickficano/Projects/taste/')
os.environ['DJANGO_SETTINGS_MODULE']='taste.settings'

from django.core.management import setup_environ
import settings
setup_environ(settings)

from django.contrib.auth.models import User
from django.db import transaction
from taste.apps.restaurants.models import Restaurant
from taste.apps.reviews.models import Review, ReviewDish, Dish, Score

def smart_unicode(s, encoding='latin-1', errors='strict'):
    if type(s) in (unicode, int, long, float, types.NoneType):
        return unicode(s)
    elif type(s) is str or hasattr(s, '__unicode__'):
        return unicode(s, encoding, errors)
    else:
        return unicode(str(s), encoding, errors)

def smart_str(s, encoding='utf-8', errors='strict', from_encoding='latin-1'):
    if type(s) in (int, long, float, types.NoneType):
        return str(s)
    elif type(s) is str:
        if encoding != from_encoding:
            return s.decode(from_encoding, errors).encode(encoding, errors)
        else:
            return s
    elif type(s) is unicode:
        return s.encode(encoding, errors)
    elif hasattr(s, '__str__'):
        return smart_str(str(s), encoding, errors, from_encoding)
    elif hasattr(s, '__unicode__'):
        return smart_str(unicode(s), encoding, errors, from_encoding)
    else:
        return smart_str(str(s), encoding, errors, from_encoding)

def cleaner(body):
    regex = re.compile(r'\s+')
    res = regex.sub(' ', body).strip()
    return res

def get_restaurant(restaurant):
    match = Restaurant.objects.filter(name=restaurant)
    if len(match) == 1:
        print "Found: `" + match[0].name + "`"
        return match[0]
    
    elif len(match) > 1:
        print "`%s` has returned MULTIPLE matches" % restaurant
        restaurant_name = raw_input('Restuaurant name: ')
        return Restaurant.objects.get(name=restaurant_name)
        
    elif len(match) == 0:
        print "`%s` has returned ZERO matches" % restaurant
        restaurant_name = raw_input('Restuaurant name: ')
        return Restaurant.objects.get(name=restaurant_name)

def process_dishes(review, recommended, dishes):
    dishes = re.split(',|;',dishes)
    parsed_dishes = list()
    if dishes:
        for dish in dishes:
            dish = dish.lower().strip()
            if dish:
                obj = Dish.objects.create(name=dish)
                ReviewDish.objects.create(dish=obj, review=review, 
                                          recommended=recommended)
def process_file(filename, user, debug=False):
    f = open(filename, 'rU')
    try:
        reader = csv.DictReader(f, dialect=csv.excel)
        users = []

        for row in reader:
            review_data = {
                'active': True,
                'user': User.objects.get(id=user),
                'restaurant': get_restaurant(row['restaurant_name']),
                'published': datetime.today(),
                'overall_score':int(row['overall_score']),
                'ambience_score': int(row['ambience_score']),
                'service_score':int(row['service_score']),
                'food_score': int(row['food_score']),
                'body': cleaner(smart_unicode(row['review'])),
                'summary': cleaner(smart_unicode(row['review'])),
                'score': Score.objects.get(value=int(row['overall_score'])),
                }

            if not debug:
                review = Review.objects.create(**review_data)
                process_dishes(review, True, row['good_dishes'])
                process_dishes(review, False, row['bad_dishes'])
            else:
                print review_data['body']
                #pprint(review_data)
    finally:
        f.close()

def run():
    join_path = lambda p1,p2: os.path.abspath(os.path.join(p1,p2))
    file_path = os.path.dirname(__file__)
    path = join_path(file_path, 'reviews')
    
    for infile in glob.glob(os.path.join(path, '*.csv')):
        filename = os.path.join(path, infile)
        base=os.path.basename(infile)
        user = int(os.path.splitext(base)[0])
        print filename
        process_file(filename, user, debug=False)

run()
