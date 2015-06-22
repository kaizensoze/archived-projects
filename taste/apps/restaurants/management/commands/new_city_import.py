import csv
from decimal import Decimal
from datetime import date

from django.contrib.sites.models import Site
from django.core.management.base import BaseCommand
from django.template.defaultfilters import slugify

from taste.apps.restaurants.models import (
    Cuisine,
    Location,
    Neighborhood,
    Occasion,
    OperatingHour,
    Price,
    Restaurant,
    DAY_CHOICES,
    HOUR_CHOICES,
)
from taste.apps.critics.models import Site as Critic, Author
from taste.apps.reviews.models import Dish, Rating, Review, ReviewDish, Score


class Command(BaseCommand):
    def err(self, msg, ending='\n'):
        self.stderr.write(msg + ending)

    def out(self, msg, ending='\n'):
        self.stdout.write(msg + ending)

    def handle(self, *args, **kwargs):
        """
        args:
            city restaurants.csv occasions.csv hours.csv reviews.csv
            city '' '' '' reviews.csv
        """
        try:
            self.city = Site.objects.get(name=args[0])
        except Site.DoesNotExist:
            self.err("No such city: {name}".format(name=args[0]))
            return

        # restaurants.csv
        if len(args[1]) > 0:
            self.out(">>> Importing restaurants...")
            contents = csv.reader(open(args[1], 'rU'))
            rows = [x for x in contents]
            for row in rows[1:]:
                self.parse_restaurant_row(row)

        # occasions.csv
        if len(args[2]) > 0:
            self.out(">>> Importing occasions...")
            contents = csv.reader(open(args[2], 'rU'))
            rows = [x for x in contents]
            for row in rows[1:]:
                self.parse_occasion_row(row)

        # hours.csv
        if len(args[3]) > 0:
            self.out(">>> Importing hours...")
            contents = csv.reader(open(args[3], 'rU'))
            rows = [x for x in contents]
            for row in rows[1:]:
                self.parse_hours_row(row)

        # reviews.csv
        if len(args[4]) > 0:
            self.out(">>> Importing critic reviews...")
            contents = csv.reader(open(args[4], 'rU'))
            rows = [x for x in contents]
            for row in rows[1:]:
                self.parse_critics_review_row(row)

    # BEGIN RESTAURANT FUNCTIONS

    def parse_name(self, name):
        return name

    def parse_url(self, url):
        if url.lower() == 'n/a' or url.lower() == 'http://':
            return ''
        else:
            return url

    def parse_opentable(self, opentable_id, opentable_url):
        if opentable_url.lower() == 'n/a' or opentable_url.lower() == 'http://':
            return ''
        elif opentable_id == '':
            return ''
        else:
            return opentable_url.lower()

    def parse_menupages(self, menupages):
        if menupages.lower() == 'n/a' or menupages.lower() == 'http://':
            return ''
        else:
            return menupages.lower()

    def parse_price(self, price):
        return Price.objects.get(name=price)

    def parse_occasion_vegetarian(self, occasion):
        if occasion == "Vegetarian Friendly":
            return Occasion.objects.get(name="Vegetarian")

    def parse_cuisines(self, *args):
        ret = []
        for cuisine in args:
            if cuisine:
                try:
                    ret.append(Cuisine.objects.get_or_create(name=cuisine)[0])
                except Cuisine.MultipleObjectsReturned:
                    self.err("Too many cuisines: %s" % cuisine)
        return ret

    def parse_neighborhoods(self, ns):
        # First, if only one has a parent, that's the one to use.
        parents = sum(bool(n.parent) for n in ns)
        if parents == 1:
            return filter(lambda x: bool(x.parent), ns)[0]
        # Then, if one has itself as its borough, it's the one to use.
        for n in ns:
            if n.borough.name == n.name:
                return n
        # Finally, use the first of the list.
        return ns[0]

    def parse_location(
            self,
            rest,
            lat,
            lng,
            phone_number,
            address,
            city,
            state,
            zip_code,
            foursquare_id,
            neighborhood,
            neighborhood_subcategory):
        try:
            n = Neighborhood.objects.get(
                name=neighborhood_subcategory,
                borough__site=self.city
            )
        except Neighborhood.DoesNotExist:
            self.err("No location {neighborhood} for {name}".format(
                neighborhood=neighborhood_subcategory,
                name=rest.name
            ))
            return
        except Neighborhood.MultipleObjectsReturned:
            # Handle duplicate neighborhoods.
            ns = Neighborhood.objects.filter(name=neighborhood_subcategory)
            n = self.parse_neighborhoods(ns)
        if foursquare_id.lower() == 'n/a':
            foursquare_id = None

        loc, created = Location.objects.get_or_create(
            restaurant=rest,
            lat=lat,
            lng=lng,
            phone_number=phone_number,
            address=address,
            city=city,
            state=state,
            zip_code=zip_code,
            foursquare_id=foursquare_id,
        )
        loc.save()
        loc.neighborhood.add(n)
        return loc

    def parse_restaurant_row(self, row):
        (
            name,
            url,
            opentable_id,
            opentable_url,
            menupages,
            price,
            # occasion,
            c1,
            c2,
            c3,
            c4,
            # hours,
            # images,
            lat,
            lng,
            phone_number,
            address,
            city,
            state,
            zip_code,
            foursquare_id,
            neighborhood,
            neighborhood_subcategory,
        ) = row

        # Let's parse this outside so we can print info about it.
        name = self.parse_name(name)
        print(name)

        r, created = Restaurant.objects.get_or_create(name=name, site=self.city)
        r.slug=slugify(name)
        r.url=self.parse_url(url)
        r.opentable=self.parse_opentable(opentable_id, opentable_url)
        r.menupages=self.parse_menupages(menupages)
        r.price=self.parse_price(price)
        r.save()
        self.parse_location(
            r,
            lat,
            lng,
            phone_number,
            address,
            city,
            state,
            zip_code,
            foursquare_id,
            neighborhood,
            neighborhood_subcategory
        )
        for c in self.parse_cuisines(c1, c2, c3, c4):
            r.cuisine.add(c)

    # END RESTAURANT FUNCTIONS
    # BEGIN OCCASION FUNCTIONS

    OCCASION_NAMES = (
        'Babies / Kids',
        'Bar Seating',
        'Breakfast',
        'Brunch',
        'Business Meeting',
        'Bustling',
        'BYOB',
        'Cash Only',
        'Casual',
        'Date Night',
        'Delivery',
        'Dessert',
        'Dining Deal %% Off',
        'Dinner with the girls',
        'Dinner with the guys',
        'Eater 38',
        'Groups',
        'Happy Hour',
        'Hipster Scene',
        'Late Night Eats',
        'Lunch',
        'NEW on the Scene',
        'Notable Chef',
        'Online Reservations',
        'Out of Town Guests',
        'Outdoor Seating',
        'Parents in Town',
        'Private Parties',
        'Quick',
        'Rustic',
        'Special Occasion',
        'WiFi',
    )

    def get_restaurant(self, name):
        try:
            return Restaurant.objects.get(name=name, site=self.city)
        except Restaurant.DoesNotExist:
            self.err("Missing restaurant: %s" % repr(name))
        except Restaurant.MultipleObjectsReturned:
            self.err("Too many restaurants: %s" % repr(name))

    def get_occasions(self, *args):
        occasions = []
        for i, cell in enumerate(args):
            if cell.strip():
                try:
                    occasion, created = Occasion.objects.get_or_create(
                        name=self.OCCASION_NAMES[i]
                    )
                except Occasion.MultipleObjectsReturned:
                    self.err("Too many occasions: {names}".format(
                        names=repr(self.OCCASION_NAMES[i])
                    ))
                else:
                    occasions.append(occasion)
        return occasions

    def parse_occasion_row(self, row):
        restaurant = self.get_restaurant(row[0])
        occasions = self.get_occasions(*row[1:])
        if restaurant:
            for occasion in occasions:
                restaurant.occasion.add(occasion)

    # END OCCASION FUNCTIONS
    # BEGIN HOUR FUNCTIONS

    def parse_hours(self, *args):
        ret = []
        days_dict = dict((k, v) for (v, k) in DAY_CHOICES)
        hours_dict = dict((k, v) for (v, k) in HOUR_CHOICES)
        hours_dict['11:59 pm'] = 24
        # Fancy-dancy way to make a list of tuples out of a flattened list.
        for day, open_hour, close_hour in zip(args[0::3], args[1::3], args[2::3]):
            if open_hour == '-' and close_hour == '-':
                continue
            if not day:
                continue
            day = days_dict[day.strip()]
            if open_hour != '-':
                open_hour = hours_dict[open_hour.lower()]
            if close_hour != '-':
                close_hour = hours_dict[close_hour.lower()]
            else:
                close_hour = hours_dict['Close']
            hours, created = OperatingHour.objects.get_or_create(
                day=day,
                open=open_hour,
                closed=close_hour,
                time_zone='US/Eastern'  # Chicago!
            )
            ret.append(hours)
        return ret

    def parse_hours_row(self, row):
        restaurant = self.get_restaurant(row[0])  # Under OCCASION FUNCTIONS
        if restaurant:
            hours = self.parse_hours(*row[1:])
            if restaurant:
                for hour in hours:
                    restaurant.hours.add(hour)

    # END HOUR FUNCTIONS
    # BEGIN CRITIC DATA FUNCTIONS

    def parse_critics_data_row(self, row):
        print(row)
        (
            critic_name,
            url,
            rating_style,
            rating_denominator,
            weight,
        ) = row
        if rating_style == 'N/A':
            rating_style = ''
        try:
            rating_denominator = int(rating_denominator)
        except ValueError:
            rating_denominator = None
        try:
            weight = int(weight[:-1])
        except ValueError:
            weight = 1
        Critic.objects.get_or_create(
            name=critic_name,
            slug=slugify(critic_name),
            url=url,
            rating_style=rating_style,
            rating_denominator=rating_denominator,
            review_weight=weight
        )

    # END CRITIC DATA FUNCTIONS
    # BEGIN CRITIC REVIEW FUNCTIONS

    def get_critic(self, critic):
        try:
            return Critic.objects.get(name=critic)
        except Critic.DoesNotExist:
            self.err("No such critic: %s" % repr(critic))
        except Critic.MultipleObjectsReturned:
            self.err("Too many critics match: %s" % repr(critic))

    def parse_score(self, score):
        if not score:
            return
        score = Decimal(score)
        return Score.objects.get(value=score)

    def parse_site_rating(self, site_rating):
        site_rating = str(site_rating)
        if not site_rating:
            return
        if site_rating.lower() == 'n/a':
            return
        return Rating.objects.get_or_create(name=site_rating)[0]

    def parse_dishes(self, dishes):
        ret = []
        dishes = [x.strip() for x in dishes.split(',')]
        for name in dishes:
            if not name:
                continue
            try:
                dish, created = Dish.objects.get_or_create(name=name)
            except Dish.MultipleObjectsReturned:
                dish = Dish.objects.filter(name=name)[0]
            ret.append(dish)
        return ret

    def parse_critics_review_row(self, row):
        (
            restaurant,
            critic,
            date_published,
            summary,
            url,
            author,
            score,
            site_rating,
            good_dishes,
            bad_dishes,
        ) = row

        restaurant = self.get_restaurant(restaurant)
        if not restaurant:
            return

        critic = self.get_critic(critic)
        if not critic:
            return

        if not date_published or date_published.lower() == 'n/a':
            date_published = None
        else:
            month, day, year = map(int, date_published.split('/'))
            date_published = date(year=year, month=month, day=day)

        url = self.parse_url(url)  # Under RESTAURANT FUNCTIONS

        author, created = Author.objects.get_or_create(
            name=author,
            site=critic
        )

        score = self.parse_score(score)

        rating = self.parse_site_rating(site_rating)

        review, created = Review.objects.get_or_create(
            restaurant=restaurant,
            summary=summary,
            published=date_published,
            score=score,
            url=url,
            author=author,
            site=critic,
            site_rating=rating
        )

        good_dishes = self.parse_dishes(good_dishes)
        for dish in good_dishes:
            ReviewDish.objects.get_or_create(
                dish=dish,
                review=review,
                recommended=True
            )

        bad_dishes = self.parse_dishes(bad_dishes)
        for dish in bad_dishes:
            ReviewDish.objects.get_or_create(
                dish=dish,
                review=review,
                recommended=False
            )

    # END CRITIC REVIEW FUNCTIOSN
