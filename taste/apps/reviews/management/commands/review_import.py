import csv, re
from multiprocessing import Pool

from django.core.management.base import BaseCommand, CommandError
from optparse import make_option

from reviews.models import *
from critics.models import *
from restaurants.models import Restaurant

RWD = {'r':1, 'w':2, 'd':3}

s = Site(id = 1, name = 'The New York Times', url = 'http://www.nytimes.com/')
s.save()
s = Site(id = 2, name = 'New York Magazine', url = 'http://www.nymag.com/')
s.save()
s = Site(id = 3, name = 'Michelin Guide', url = 'http://www.michelinguide.com/')
s.save()

def process_review(review):
    if review['name']:
        r = Review()

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
                r.rating = Rating.objects.get(name = review['score'])
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
        make_option('--mag-path', '-q', dest='magpath', help="Path to NY Mag CSV"),
        make_option('--michelin-path', '-r', dest='michelinpath', help="Path to Michelin CSV"),
    )
    def handle(self, *args, **options):
        if not options['timespath'] or not options['magpath'] or not options['michelinpath']:
            raise CommandError('All Path Argument Required: --times-path, mag-path, michelin-path="/path/to/restaurants.csv"')
        else:
            nytimes = csv.DictReader(open(options['timespath'], 'rb'), dialect='excel')
            nytimes = list(nytimes)

            nymag = csv.DictReader(open(options['magpath'], 'rb'), dialect='excel')
            nymag = list(nymag)

            michelin = csv.DictReader(open(options['michelinpath'], 'rb'), dialect='excel')
            michelin = list(michelin)

            reviews = nytimes + nymag + michelin

            scores = [review['ts-score'].replace(' ', '') for review in reviews if review['ts-score']]
            scores = list(set(scores))

            for score in scores:
                score = Score(value=score)
                score.save()

            ratings = [review['score'].replace(' ', '') for review in reviews if review['score']]
            ratings = list(set(ratings))

            for rating in ratings:
                rating = Rating(name=rating)
                rating.save()
                
            map(process_review, reviews)