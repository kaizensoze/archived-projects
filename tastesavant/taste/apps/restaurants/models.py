from datetime import datetime

from decimal import Decimal
from django.contrib.localflavor.us import models as us_models
from django.contrib.sites.models import Site
from django.contrib.sites.managers import CurrentSiteManager
from django.template.defaultfilters import slugify
from django.core.urlresolvers import reverse
from django.db import models
from django.db.models import Avg
from django.utils.timezone import now
from djangosphinx.models import SphinxSearch
from mptt.models import MPTTModel, TreeForeignKey

from positions.fields import PositionField

from taste.apps.singleplatform.models import Menu
from .managers import (
    RestaurantCurrentSiteManager,
    RestaurantSpecialQueriesManager,
)

import pytz


# Utils:
def get_cuisine_parents(cuisine_list):
    # cuisines = Cuisine.objects.filter(id__in=cuisine_id_list)
    cuisine_ancestors = []
    for cuisine in cuisine_list:
        cuisine_ancestors.append(cuisine.get_ancestors(include_self=True))
    if cuisine_ancestors:
        return reduce(
            lambda x, y: x | y,
            cuisine_ancestors
        ).exclude(name='Cuisines')
    else:
        return cuisine_ancestors

DAY_CHOICES = (
    (0, 'Sunday'),
    (1, 'Monday'),
    (2, 'Tuesday'),
    (3, 'Wednesday'),
    (4, 'Thursday'),
    (5, 'Friday'),
    (6, 'Saturday'),
)

HOUR_CHOICES = (
    (Decimal('1.00'),  '1:00 am'),
    (Decimal('1.25'),  '1:15 am'),
    (Decimal('1.50'),  '1:30 am'),
    (Decimal('1.75'),  '1:45 am'),
    (Decimal('2.00'),  '2:00 am'),
    (Decimal('2.25'),  '2:15 am'),
    (Decimal('2.50'),  '2:30 am'),
    (Decimal('2.75'),  '2:45 am'),
    (Decimal('3.00'),  '3:00 am'),
    (Decimal('3.25'),  '3:15 am'),
    (Decimal('3.50'),  '3:30 am'),
    (Decimal('3.75'),  '3:45 am'),
    (Decimal('4.00'),  '4:00 am'),
    (Decimal('4.25'),  '4:15 am'),
    (Decimal('4.50'),  '4:30 am'),
    (Decimal('4.75'),  '4:45 am'),
    (Decimal('5.00'),  '5:00 am'),
    (Decimal('5.25'),  '5:15 am'),
    (Decimal('5.50'),  '5:30 am'),
    (Decimal('5.75'),  '5:45 am'),
    (Decimal('6.00'),  '6:00 am'),
    (Decimal('6.25'),  '6:15 am'),
    (Decimal('6.50'),  '6:30 am'),
    (Decimal('6.75'),  '6:45 am'),
    (Decimal('7.00'),  '7:00 am'),
    (Decimal('7.25'),  '7:15 am'),
    (Decimal('7.50'),  '7:30 am'),
    (Decimal('7.75'),  '7:45 am'),
    (Decimal('8.00'),  '8:00 am'),
    (Decimal('8.25'),  '8:15 am'),
    (Decimal('8.50'),  '8:30 am'),
    (Decimal('8.75'),  '8:45 am'),
    (Decimal('9.00'),  '9:00 am'),
    (Decimal('9.25'),  '9:15 am'),
    (Decimal('9.50'),  '9:30 am'),
    (Decimal('9.75'),  '9:45 am'),
    (Decimal('10.00'), '10:00 am'),
    (Decimal('10.25'), '10:15 am'),
    (Decimal('10.50'), '10:30 am'),
    (Decimal('10.75'), '10:45 am'),
    (Decimal('11.00'), '11:00 am'),
    (Decimal('11.25'), '11:15 am'),
    (Decimal('11.50'), '11:30 am'),
    (Decimal('11.75'), '11:45 am'),
    (Decimal('12.00'), '12:00 pm'),
    (Decimal('12.25'), '12:15 pm'),
    (Decimal('12.50'), '12:30 pm'),
    (Decimal('12.75'), '12:45 pm'),
    (Decimal('13.00'), '1:00 pm'),
    (Decimal('13.25'), '1:15 pm'),
    (Decimal('13.50'), '1:30 pm'),
    (Decimal('13.75'), '1:45 pm'),
    (Decimal('14.00'), '2:00 pm'),
    (Decimal('14.25'), '2:15 pm'),
    (Decimal('14.50'), '2:30 pm'),
    (Decimal('14.75'), '2:45 pm'),
    (Decimal('15.00'), '3:00 pm'),
    (Decimal('15.25'), '3:15 pm'),
    (Decimal('15.50'), '3:30 pm'),
    (Decimal('15.75'), '3:45 pm'),
    (Decimal('16.00'), '4:00 pm'),
    (Decimal('16.25'), '4:15 pm'),
    (Decimal('16.50'), '4:30 pm'),
    (Decimal('16.75'), '4:45 pm'),
    (Decimal('17.00'), '5:00 pm'),
    (Decimal('17.25'), '5:15 pm'),
    (Decimal('17.50'), '5:30 pm'),
    (Decimal('17.75'), '5:45 pm'),
    (Decimal('18.00'), '6:00 pm'),
    (Decimal('18.25'), '6:15 pm'),
    (Decimal('18.50'), '6:30 pm'),
    (Decimal('18.75'), '6:45 pm'),
    (Decimal('19.00'), '7:00 pm'),
    (Decimal('19.25'), '7:15 pm'),
    (Decimal('19.50'), '7:30 pm'),
    (Decimal('19.75'), '7:45 pm'),
    (Decimal('20.00'), '8:00 pm'),
    (Decimal('20.25'), '8:15 pm'),
    (Decimal('20.50'), '8:30 pm'),
    (Decimal('20.75'), '8:45 pm'),
    (Decimal('21.00'), '9:00 pm'),
    (Decimal('21.25'), '9:15 pm'),
    (Decimal('21.50'), '9:30 pm'),
    (Decimal('21.75'), '9:45 pm'),
    (Decimal('22.00'), '10:00 pm'),
    (Decimal('22.25'), '10:15 pm'),
    (Decimal('22.50'), '10:30 pm'),
    (Decimal('22.75'), '10:45 pm'),
    (Decimal('23.00'), '11:00 pm'),
    (Decimal('23.25'), '11:15 pm'),
    (Decimal('23.50'), '11:30 pm'),
    (Decimal('23.75'), '11:45 pm'),
    (Decimal('24.00'), '12:00 am'),
    (Decimal('24.25'), '12:15 am'),
    (Decimal('24.50'), '12:30 am'),
    (Decimal('24.75'), '12:45 am'),
    (Decimal('25.00'), '24 Hours'),
    (Decimal('0.00'),  'Close'),
)

US_TIME_ZONES = tuple((tz, tz.split('/')[1]) for tz in pytz.all_timezones if 'US' in tz)


class OperatingHour(models.Model):
    day = models.IntegerField(choices=DAY_CHOICES)
    open = models.DecimalField(max_digits=4, decimal_places=2,
                               choices=HOUR_CHOICES)
    closed = models.DecimalField(max_digits=4, decimal_places=2,
                                 choices=HOUR_CHOICES)
    time_zone = models.CharField(max_length=255, choices=US_TIME_ZONES,
                                 default='US/Eastern')

    def __unicode__(self):
        return u'%s open: %s, close: %s' % (
            self.get_day_display(), self.get_open_display(),
            self.get_closed_display())

    def save(self, *args, **kwargs):
        try:
            oh = OperatingHour.objects.get(
                day=self.day,
                open=self.open,
                closed=self.closed,
                time_zone=self.time_zone
            )
            self.id = oh.id
        except OperatingHour.DoesNotExist:
            pass
        super(OperatingHour, self).save(*args, **kwargs)

    def within_open_hours(self, date_time):
        """
        >>> tz = pytz.timezone('America/New_York')
        >>> hour = OperatingHour(day=1, open=Decimal('11'), closed=Decimal('15'))
        >>> hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 19, 13))
        ... )
        True
        >>> hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 20, 13))
        ... )
        False
        >>> hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 19, 15, 15))
        ... )
        False
        >>> hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 19, 10, 45))
        ... )
        False
        >>> late_hour = OperatingHour(day=1, open=Decimal('11'), closed=Decimal('2'))
        >>> late_hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 19, 13))
        ... )
        True
        >>> late_hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 20, 1))
        ... )
        True
        >>> late_hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 20, 2, 15))
        ... )
        False
        >>> late_hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 20, 13))
        ... )
        False
        >>> late_hour.within_open_hours(
        ...     tz.localize(datetime(2013, 8, 19, 1))
        ... )
        False
        """
        # Shift to appropriate timezone. Assuming that we get input with TZ
        # data attached.
        tz = pytz.timezone(self.time_zone)
        date_time = date_time.astimezone(tz)
        is_latenight = self.open > self.closed
        weekday = date_time.isoweekday() % 7  # Because 0-indexed sundays.
        if self.day == weekday and (self.open == 25 or self.closed == 25):
            # 24 hours this day.
            return True
        time = date_time.time()
        # Decimals and floats can't compare, floats can't become decimals, the
        # world is a sad and miserable place. But with the magic of two
        # conversions, we can get a comparable decimal_time value.
        decimal_time = Decimal(str(time.hour + (time.minute / 60.0)))
        if is_latenight and decimal_time < self.closed:
            # Count it as the previous day if we're open late and out late.
            weekday = (weekday - 1) % 7
        if time.hour == 0:
            # Midnight is 24.
            decimal_time += 24
        if self.day == weekday:
            if not is_latenight:
                return self.open <= decimal_time <= self.closed
            else:
                # Er, why does this work? My boolean brain has failed. This
                # isn't just the converse of the above, as it seems to account
                # for a different set of conditions, when
                # self.open > self.closed.
                return not (self.open >= decimal_time >= self.closed)
        else:
            return False

    class Meta:
        ordering = ['day', 'open']
        unique_together = ('day', 'open', 'closed', 'time_zone',)


class Cuisine(MPTTModel):
    name = models.CharField(max_length=255, unique=True)
    parent = TreeForeignKey('self', null=True, blank=True,
                            related_name='children')
    position = PositionField(collection='parent')

    class MPTTMeta:
        order_insertion_by = ('position', 'name')

    def save(self, *args, **kwargs):
        ret = super(Cuisine, self).save(*args, **kwargs)
        self.__class__.tree.rebuild()  # Gotta keep the tree in order, alas.
        return ret

    def __unicode__(self):
        return self.name


class Occasion(models.Model):
    name = models.CharField(max_length=255, unique=True)
    site = models.ManyToManyField(Site, null=True, blank=True)
    active = models.BooleanField(default=True)

    class Meta:
        ordering = ['name']

    def __unicode__(self):
        return self.name


class Price(models.Model):
    name = models.CharField(max_length=24, unique=True)

    class Meta:
        ordering = ['name']

    def __unicode__(self):
        return self.name


class Restaurant(models.Model):
    search = SphinxSearch()

    added = models.DateTimeField(auto_now_add=True)
    active = models.BooleanField(default=True)
    name = models.CharField(max_length=255)
    slug = models.SlugField(max_length=255, unique=True, db_index=True)
    url = models.URLField(max_length=2048, blank=True)
    opentable = models.URLField(max_length=2048, blank=True)
    kitchensurfing = models.URLField(max_length=2048, blank=True)
    menupages = models.URLField(max_length=2048, blank=True)
    price = models.ForeignKey(Price, null=True)
    hours = models.ManyToManyField(OperatingHour)
    occasion = models.ManyToManyField(Occasion)
    cuisine = models.ManyToManyField(Cuisine)
    hits = models.IntegerField(default=0)
    friends_score = None
    critics_say = models.DecimalField(
        max_digits=3,
        decimal_places=1,
        null=True,
        default=None,
        blank=True
    )
    savants_say = models.DecimalField(
        max_digits=3,
        decimal_places=1,
        null=True,
        default=None,
        blank=True
    )

    site = models.ForeignKey(Site)
    objects = RestaurantSpecialQueriesManager()
    on_site = RestaurantCurrentSiteManager()

    @property
    def within_open_hours(self):
        now_ = now()
        return any([x.within_open_hours(now_) for x in self.hours.all()])

    def locations(self):
        return self.location_set.exclude(lat=0, lng=0)

    def good_dishes(self):
        dishes = []
        for review in self.reviews.all():
            dishes = dishes + list(review.good_dishes)
        return dishes

    @property
    def positive(self):
        return self.reviews.filter(score__value__gte=8).count()

    @property
    def negative(self):
        return self.reviews.filter(score__value__lte=3).count()

    @property
    def _critics_say(self):
        # This is a weighted average, so we have to compute it here in the
        # Python
        # Some prefetch_related would speed this up, waiting for Django 1.4.
        queryset = self.reviews.filter(
            active=True,
            user__isnull=True
        )
        if not queryset:
            return None
        weighted_numerator = sum([r.score.value * r.site.review_weight for r in queryset if r.site is not None])
        weighted_numerator += sum([r.score.value for r in queryset if r.site is None])
        weighted_denominator = sum([r.site.review_weight for r in queryset if r.site is not None])
        weighted_denominator += sum([1 for r in queryset if r.site is None])
        return Decimal(str(weighted_numerator / weighted_denominator))

    @property
    def critics_say_rwd(self):
        if self.critics_say is None:
            return "Not Rated"
        else:
            critics_say = round(self.critics_say)
            if critics_say >= 0 and critics_say <= 4:
                return 'skip'
            if critics_say >= 5 and critics_say <= 7:
                return 'like'
            if critics_say >= 8 and critics_say <= 10:
                return 'love'

    @property
    def large_critics_say_rwd_url(self):
        if self.critics_say is None:
            return "images/rwd/not-rated.45x45.png"
        return "images/rwd/%s.45x45.png" % slugify(self.critics_say_rwd)

    @property
    def _savants_say(self):
        ret = self.reviews.filter(
            active=True, user__isnull=False).aggregate(
            overall=Avg('overall_score'))['overall']
        if ret is not None:
            return Decimal(str(ret))
        else:
            return ret

    @property
    def savants_say_rwd(self):
        if self.savants_say is None:
            return "Not Rated"
        else:
            savants_say = round(self.savants_say)
            if savants_say >= 0 and savants_say <= 4:
                return 'skip'
            if savants_say >= 5 and savants_say <= 7:
                return 'like'
            if savants_say >= 8 and savants_say <= 10:
                return 'love'

    @property
    def large_savants_say_rwd_url(self):
        if self.savants_say is None:
            return "images/rwd/not-rated.45x45.png"
        return "images/rwd/%s.45x45.png" % slugify(self.savants_say_rwd)

    @property
    def friends_say_rwd(self):
        if self.friends_score is None:
            return "Not Rated"
        else:
            friends_say = round(self.friends_score)
            if friends_say >= 0 and friends_say <= 4:
                return 'skip'
            if friends_say >= 5 and friends_say <= 7:
                return 'like'
            if friends_say >= 8 and friends_say <= 10:
                return 'love'

    @property
    def large_friends_say_rwd_url(self):
        if self.friends_score is None:
            return "images/rwd/not-rated.45x45.png"
        return "images/rwd/%s.45x45.png" % slugify(self.friends_say_rwd)

    @property
    def total_critic_review_count(self):
        return self.reviews.filter(active=True, user__isnull=True).count()

    @property
    def total_user_review_count(self):
        return self.reviews.filter(active=True, user__isnull=False).count()

    @property
    def total_review_count(self):
        """
        Should always equal total_critic_review_count +
        total_user_review_count, but making a distinct single call to the DB
        here is marginally faster.
        """
        return self.reviews.filter(active=True).count()

    @property
    def rwd(self):
        if self.score is None:
            return "Not Rated"
        else:
            score = round(self.score)
            if score >= 0 and score <= 4:
                return 'Ditch'
            if score >= 5 and score <= 7:
                return 'Walk'
            if score >= 8 and score <= 10:
                return 'Run'

    # @note: Avoid one-letter variable names. Just increases readability. --kit
    # @todo: this can probably be handled more directly through the DB, might
    # speed it up. --kit
    @property
    def score(self):
        r = self.reviews.all()
        if r.count():
            values = []
            for i in r:
                if i.score:
                    values.append(i.score.value)
            average = sum(values) / len(values)
            return average
        else:
            return None

    def add_parent_cuisines(self):
        for c in get_cuisine_parents(self.cuisine.all()):
            self.cuisine.add(c)

    def save(self, *args, **kwargs):
        self.critics_say = self._critics_say
        self.savants_say = self._savants_say
        ret = super(Restaurant, self).save(*args, **kwargs)
        self.add_parent_cuisines()
        return ret

    class Meta:
        ordering = ['active', 'name']

    @property
    def _get_api_url(self):
        # @todo: the protocol should be https.
        uri_root = "http://" + Site.objects.get_current().domain
        return uri_root + reverse('api-restaurant-instance',
            kwargs={'slug': self.slug})

    @property
    def _reviews(self):
        return self._get_api_url + 'reviews/'

    @property
    def has_menu(self):
        return bool(Menu.objects.filter(restaurant=self).count() or self.menupages)

    @property
    def has_local_menu(self):
        return bool(Menu.objects.filter(restaurant=self).count())

    def get_menu_url(self):
        if Menu.objects.filter(restaurant=self).count():
            return self.get_absolute_url() + "menu/"
        return self.menupages

    def get_absolute_url(self):
        return u"/restaurant/{slug}/".format(slug=self.slug)

    def __unicode__(self):
        return self.name

    # @note: Gotta be a better way to do this. Also, static method? --kit
    def areconsecutive(self, days):
        return days in [['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
                ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
                ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'],
                ['Sunday', 'Monday', 'Tuesday', 'Wednesday'],
                ['Sunday', 'Monday', 'Tuesday'],
                ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
                ['Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
                ['Wednesday', 'Thursday', 'Friday', 'Saturday'],
                ['Thursday', 'Friday', 'Saturday'],
                ['Monday', 'Tuesday', 'Wednesday'],
                ['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
                ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
                ['Tuesday', 'Wednesday', 'Thursday', 'Friday'],
                ['Tuesday', 'Wednesday', 'Thursday'],
                ['Wednesday', 'Thursday', 'Friday']]

    def human_readable_hours(self):
        hours = self.hours.all()
        common = set((
                hour.get_open_display().replace(' ', '').replace(':00', ''),
                hour.get_closed_display().replace(' ', '').replace(':00', '')) for hour in hours)

        human = {}
        for open in common:
            human[open] = []
            for hour in hours:
                if (hour.get_open_display().replace(' ', '').replace(':00', ''),
                    hour.get_closed_display().replace(' ', '').replace(':00', '')) == open:
                    human[open].append(hour.get_day_display())

        hourstring = ''
        for hours, days in human.items():
            if len(days) < 3 or not self.areconsecutive(days):
                for day in days:
                    hourstring = hourstring + day[0:3] + ', '
                hourstring = hourstring.rstrip(', ') + ': ' + hours[0] + ' - ' + hours[1] + ', '
            else:
                length = len(days)
                hourstring = hourstring + days[0][0:3] + '-' + days[length - 1][0:3] + ': ' + hours[0] + ' - ' + hours[1] + ', '
        return hourstring.rstrip(', ')

    @property
    def image_url(self):
        images = self.images.all()
        if images:
            return images[0].image.url
        else:
            return ''


class Borough(models.Model):
    name = models.CharField(max_length=255)

    site = models.ForeignKey(Site)
    objects = models.Manager()
    on_site = CurrentSiteManager()

    def __unicode__(self):
        return self.name


class Neighborhood(MPTTModel):
    name = models.CharField(max_length=255)
    borough = models.ForeignKey(Borough)
    parent = TreeForeignKey('self', null=True, blank=True,
                            related_name='children')
    position = PositionField(collection='parent')

    class MPTTMeta:
        order_insertion_by = ('position', )

    def save(self, *args, **kwargs):
        ret = super(Neighborhood, self).save(*args, **kwargs)
        self.__class__.tree.rebuild()  # Gotta keep the tree in order, alas.
        return ret

    def __unicode__(self):
        return self.name


class Location(models.Model):
    restaurant = models.ForeignKey(Restaurant)
    neighborhood = models.ManyToManyField(Neighborhood)
    lat = models.FloatField(default=0)
    lng = models.FloatField(default=0)
    phone_number = us_models.PhoneNumberField()
    address = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    state = us_models.USStateField()
    zip_code = models.CharField(max_length=10)
    foursquare_id = models.CharField(max_length=255, null=True, blank=True)
    singleplatform_id = models.CharField(max_length=255, null=True, blank=True)
    seamless_direct_url = models.URLField(max_length=2048, blank=True)
    seamless_mobile_url = models.URLField(max_length=2048, blank=True)
    grubhub_url = models.URLField(max_length=2048, blank=True)

    class Meta:
        ordering = ['restaurant__name']

    def __unicode__(self):
        return u'%s : %s, %s' % (self.restaurant.name, self.address, self.city)


def image_path_handler(instance, filename):
    return u"restaurants/{restaurant_name}/{file}".format(
        restaurant_name=instance.restaurant.name,
        file=filename
    )


class RestaurantImage(models.Model):
    restaurant = models.ForeignKey(Restaurant, related_name='images')
    image = models.ImageField(upload_to=image_path_handler, max_length=255)
    order_index = models.IntegerField(default=0)
    credit = models.CharField(max_length=255, unique=False, blank=True)

    class Meta:
        ordering = ['order_index']
