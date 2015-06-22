from django.core.management.base import BaseCommand, CommandError
from optparse import make_option
from apps.reviews.models import Review
from django.template.defaultfilters import slugify

from taste.apps.restaurants.models import *

class Command(BaseCommand):
    help = "Updates the critic score for all restaurants"

    def handle(self, *args, **options):
        restaurants = Restaurant.objects.all()
        try:
            for restaurant in restaurants:
                self.stdout.write("%s\n" % restaurant.name)
                restaurant.save()
                self.stdout.write("Restaurant score for %s updated\n" % restaurant.name)
            self.stdout.write("%s records were updated\n" % Restaurant.objects.all().count())
        except:
            self.stdout.write("Error - no restaurants were updated")


        reviews = Review.objects.all()
        self.stdout.write("Have %s reviews to update" % reviews.count())
        try:
            for review in reviews:
                review.save()
                self.stdout.write("Review score for %s updated\n" % review.restaurant)
        except:
            self.stdout.write("Error - no reviews were updated")


