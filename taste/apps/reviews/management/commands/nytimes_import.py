import csv, re
from multiprocessing import Pool

from django.core.management.base import BaseCommand, CommandError
from optparse import make_option

from reviews.models import *
from critics.models import *
from restaurants.models import Restaurant

RWD = {'r':1, 'w':2, 'd':3}

def process_review(review):
    if review['name'] and review['summary']:
        r = Review()
        print review['name']
        r.summary = review['summary']
        
        if review['date']:
            r.published = review['date']

        r.site = Site.objects.get(id = int(review['site']))

        if review.has_key('author') and review['author']:
            try:
                r.author = Author.objects.get(name = review['author'])
            except Author.DoesNotExist:
                a = Author(name = review['author'], site = r.site)
                a.save()
                r.author = a

        if review.has_key('ts-score') and review['ts-score']:
            try:
                r.score = Score.objects.get(value = review['ts-score'])
            except Score.DoesNotExist:
                pass

        if review.has_key('score') and review['score']:
            try:
                r.site_rating = Rating.objects.get(name = review['score'])
            except Rating.DoesNotExist:
                pass 

        if review.has_key('url') and review['url']:
            r.url = review['url']

        if review.has_key('rwd') and review['rwd']:
            r.rwd = RWD[review['rwd'].lower()]

        try:
            r.restaurant = Restaurant.objects.get(name = review['name'])
        except Restaurant.DoesNotExist:
            r.active=False
            r._name = review['name']
        
        r.save()
        
        if review.has_key('recommended') and review['recommended']:
            rdishes = re.sub('[0-9)]', '', review['recommended'])
            rdishes = [dish.strip().lower() for dish in rdishes.split(',')]
            
            for dish in rdishes:
                try:
                    d = Dish.objects.get(name = dish)
                except:
                    d = Dish(name= dish)
                    d.save()
                rd = ReviewDish(dish=d, review = r)
                rd.save()

        if review.has_key('avoid') and review['avoid']:
            adishes = re.sub('[0-9)]', '', review['avoid'])
            adishes = [dish.strip().lower() for dish in adishes.split(',')]
            
            for dish in adishes:
                try:
                    d = Dish.objects.get(name = dish)
                except:
                    d = Dish(name= dish)
                    d.save()
                rd = ReviewDish(dish=d, review = r, recommended=False)
                rd.save()

class Command(BaseCommand):
    help = "Import data from Excel CSV files... run once!"
    option_list = BaseCommand.option_list + (
        make_option('--times-path', '-p', dest='timespath', help="Path to NY Times CSV"),
    )
    def handle(self, *args, **options):
        if not options['timespath']:
            raise CommandError('All Path Argument Required: --times-path, mag-path, michelin-path="/path/to/restaurants.csv"')
        else:
            reviews = csv.DictReader(open(options['timespath'], 'rb'), dialect='excel')
            reviews = list(reviews)
                
            map(process_review, reviews)
