import datetime

from django.contrib.auth.models import User
from django.db import models
from taste.apps.newsfeed.models import Activity, Action
from django.db.models.signals import post_save

from taste.apps.restaurants.models import Restaurant


class Collection(models.Model):
    user = models.ForeignKey(User)
    created = models.DateTimeField(auto_now=True)
    title = models.CharField(max_length=255)

    def __unicode__(self):
        return self.title

    def get_absolute_url(self):
        return "/blackbook/%s/" % self.user.username


class Entry(models.Model):
    collection = models.ForeignKey(Collection)
    created = models.DateTimeField(auto_now=True, null=True)
    updated = models.DateTimeField(
        default=datetime.datetime.now(),
        auto_now=True,
        auto_now_add=True,
        null=True
    )
    entry = models.CharField(max_length=255, null=True, blank=True)
    restaurant = models.ForeignKey(Restaurant, null=True)

    def __unicode__(self):
        return self.entry

def activity(sender, instance, created, **kwargs):
    """
    This posts to the activity feed.
    """
    from datetime import datetime

    user = instance.collection.user
    if not user:
        return

    name = instance.restaurant.name
    url = instance.collection.get_absolute_url()
    occurred = datetime.now()
    action = Action.objects.get(action_name='blackbook')
    metadata = {'name': name, 'url': url}

    Activity.objects.create(
        user=user,
        action=action,
        meta_data=metadata,
        occurred=occurred,
        restaurant=instance.restaurant
    )

post_save.connect(activity, sender=Entry, dispatch_uid="Entry.activity")