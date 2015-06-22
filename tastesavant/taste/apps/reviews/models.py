import datetime

from django.utils import timezone
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.db import models
from django.db.models.signals import post_save
from django.template.defaultfilters import slugify
from taste.apps.critics.models import Author, Site
from taste.apps.newsfeed.models import Activity, Action
from taste.apps.restaurants.models import Restaurant, Occasion

from .managers import ReviewManager

RWD_CHOICES = ((1, 'Love'), (2, 'Like'), (3, 'Skip'))


class Rating(models.Model):
    name = models.CharField(max_length=255, unique=True)
    description = models.CharField(max_length=1024, blank=True)
    star_rating = models.BooleanField(default=True)

    class Meta:
        ordering = ['name']

    def __unicode__(self):
        return self.name


class Score(models.Model):
    value = models.DecimalField(max_digits=4, decimal_places=2)
    description = models.CharField(max_length=1024, blank=True)

    def __unicode__(self):
        return u'%.2f' % self.value

    class Meta:
        ordering = ['value']


class Dish(models.Model):
    name = models.CharField(max_length=255)

    def __unicode__(self):
        return self.name


class Review(models.Model):
    objects = ReviewManager()
    all_objects = models.Manager()

    active = models.BooleanField(default=True)
    _name = models.CharField(blank=True, max_length=255, help_text="""
        This is only populated if the restaurant couldn't be found (with the
        initial import it's by name which is flaky) in our database. Please
        choose the correct restaurant and activate the review... This field
        is temporary and should/will be removed at somepoint.""")
    restaurant = models.ForeignKey(
        Restaurant,
        null=True,
        related_name="reviews"
    )
    body = models.TextField(blank=True)
    summary = models.TextField(blank=True)
    published = models.DateField(
        default=datetime.date.today,
        blank=True,
        null=True
    )
    created = models.DateTimeField(auto_now_add=True)
    edited = models.DateTimeField(auto_now=True, default=datetime.datetime.now)
    food_score = models.PositiveIntegerField(null=True)
    ambience_score = models.PositiveIntegerField(null=True)
    service_score = models.PositiveIntegerField(null=True)
    overall_score = models.PositiveIntegerField(null=True)
    more_tips = models.ManyToManyField(Occasion, null=True)
    score = models.ForeignKey(Score)
    url = models.URLField(max_length=2048, blank=True)
    author = models.ForeignKey(Author, related_name='author_reviews',
                               null=True, blank=True)
    site = models.ForeignKey(Site, related_name='site_reviews',
                             null=True, blank=True)
    site_rating = models.ForeignKey(Rating, null=True, blank=True)
    rwd = models.IntegerField(
        choices=RWD_CHOICES,
        verbose_name="Love, Like, or Skip",
        blank=True
    )
    user = models.ForeignKey(User, null=True, blank=True)
    vote = models.IntegerField(default=0)

    dishes = models.ManyToManyField(
        Dish,
        null=True,
        blank=True,
        through='ReviewDish'
    )

    post_to_twitter = models.BooleanField(default=False)
    post_to_facebook = models.BooleanField(default=False)

    created_via_app = models.BooleanField(
        "Mobile activity",
        default=False
    )

    # def clean(self, *args, **kwargs):
    #     if not (self.user or self.site):
    #         raise ValidationError("One of User and Site is required.")
    #     if self.user and self.site:
    #         raise ValidationError("Only one of User and Site is allowed.")

    def _rwd_generator(self, size):
        size = {
            'small': '34x34',
            'large': '48x48',
        }.get(size)
        return 'images/rwd/%s.%s.png' % (slugify(self.get_rwd_display()), size)

    @property
    def display_date(self):
        return self.published

    @property
    def small_rwd(self):
        return self._rwd_generator('small')

    @property
    def large_rwd(self):
        return self._rwd_generator('large')

    def number_of_stars(self):
        if self.site_rating and self.site_rating.star_rating:
            """
            Simple check, but best we can do right now w/o a DB change.
            If site_rating is more than 5 characters, it's probably not
            a star rating and return zero stars accordingly.
            """
            rating_len = len(self.site_rating.name.replace(' ', ''))
            if rating_len > 5:
                return 0
            else:
                return rating_len
        else:
            return None

    @property
    def good_dishes(self):
        return self.dishes.filter(reviewdish__recommended=True)

    @property
    def bad_dishes(self):
        return self.dishes.filter(reviewdish__recommended=False)

    def save(self, *args, **kwargs):
        try:
            self.score
        except Score.DoesNotExist:
            self.score = Score.objects.get(value=self.overall_score)
        if self.score.value >= 0 and self.score.value <= 4:
            self.rwd = 3
        if self.score.value > 4 and self.score.value <= 7:
            self.rwd = 2
        if self.score.value > 7 and self.score.value <= 10:
            self.rwd = 1
        super(Review, self).save(*args, **kwargs)
        self.restaurant.save()  # pass rating over there

    def __unicode__(self):
        return u'%s: %s  %s' % (
            self.restaurant,
            self.get_rwd_display(),
            self.site
        )

    class Meta:
        ordering = ('-edited', 'restaurant__name',)


class ReviewDish(models.Model):
    dish = models.ForeignKey(Dish)
    review = models.ForeignKey(Review)
    recommended = models.BooleanField(
        default=True,
        help_text="Unchecked is 'not recommended', checked is 'recommended'"
    )

    def __unicode__(self):
        return 'recommended: % s' % (self.recommended)


def activity(sender, instance, created, **kwargs):
    """
    This posts to the activity feed, and to Twitter or Facebook if asked to.
    """
    from datetime import datetime
    if not instance.active:
        return
    user = instance.user
    if not user:
        return
    name = instance.restaurant.name
    url = instance.restaurant.get_absolute_url() + 'review/savants/'
    occurred = datetime.now()
    action = Action.objects.get(action_name='reviewed')
    metadata = {'name': name, 'url': url}

    # Conceptually, this is a get, not a filter. But we have old data in the
    # database from before review activities were unique by user x
    # restaurant, so we have to filter, and then get the most recent.
    activities = Activity.objects.filter(
        user=user,
        action=action,
        restaurant=instance.restaurant
    ).order_by('-occurred')
    if activities:
        a = activities[0]
        a.occurred = occurred
        a.save()
    else:
        # Or, failing that, we make a new activity!
        Activity.objects.create(
            user=user,
            action=action,
            meta_data=metadata,
            occurred=occurred,
            restaurant=instance.restaurant
        )


post_save.connect(activity, sender=Review, dispatch_uid="Review.activity")
