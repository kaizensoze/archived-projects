import csv
from django.contrib.auth.models import User
from django.core.management.base import BaseCommand, CommandError

from taste.apps.restaurants.models import Restaurant
from taste.apps.reviews.models import Dish, Review, ReviewDish

class Command(BaseCommand):
    def _parse_restaurant(self, name):
        try:
            return Restaurant.objects.get(name=name)
        except Restaurant.DoesNotExist:
            raise CommandError("No such restaurant: %s on row %s" % (name, self.row))
        except Restaurant.MultipleObjectsReturned:
            raise CommandError("Too many restaurants: %s on row %s" % (name, self.row))

    def _parse_user(self, name):
        try:
            return User.objects.get(username=name)
        except User.DoesNotExist:
            raise CommandError("No such user: %s on row %s" % (name, self.row))
        except User.MultipleObjectsReturned:
            raise CommandError("Too many users: %s on row %s" % (name, self.row))

    def _parse_score(self, score):
        try:
            return int(float(score))
        except ValueError:
            return None

    def _parse_dishes(self, review, dishes, good=True):
        for dish in dishes.split(','):
            name = dish.strip()
            if name:
                dish = Dish.objects.create(name=name)
                ReviewDish.objects.create(
                    dish=dish,
                    review=review,
                    recommended=good
                )

    def _parse_row(self, row):
        (
            restaurant_name,
            user_name,
            overall_score,
            food_score,
            ambience_score,
            service_score,
            review,
            good_dishes,
            bad_dishes
        ) = row
        restaurant = self._parse_restaurant(restaurant_name)
        user = self._parse_user(user_name)
        overall_score = self._parse_score(overall_score)
        food_score = self._parse_score(food_score)
        ambience_score = self._parse_score(ambience_score)
        service_score = self._parse_score(service_score)
        review = Review(
            restaurant=restaurant,
            user=user,
            body=review,
            summary=review,
            overall_score=overall_score,
            food_score=food_score,
            ambience_score=ambience_score,
            service_score=service_score,
        )
        review.save()
        good_dishes = self._parse_dishes(review, good_dishes, good=True)
        bad_dishes = self._parse_dishes(review, bad_dishes, good=False)

    def handle(self, *args, **kwargs):
        with open(args[0]) as f:
            contents = csv.reader(f)
            rows = list(contents)
        rows = rows[1:]  # Strip header row
        for i, row in enumerate(rows):
            self.row = i + 1
            self._parse_row(row)
