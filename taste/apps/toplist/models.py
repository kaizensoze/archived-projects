from django.contrib.sites.models import Site
from django.contrib.sites.managers import CurrentSiteManager
from django.db import models
from taste.apps.restaurants.models import Restaurant

class TopList(models.Model):
    name = models.CharField(max_length = 255)
    active = models.BooleanField()
    site = models.ForeignKey(Site)
    objects = models.Manager()
    on_site = CurrentSiteManager()

    def __unicode__(self):
        return self.name

class TopListEntry(models.Model):
    toplist = models.ForeignKey(TopList, related_name='entries')
    restaurant = models.ForeignKey(Restaurant)
    ranking = models.IntegerField(default=0)

    class Meta:
        ordering = ['ranking']
    
