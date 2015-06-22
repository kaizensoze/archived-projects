from django.db import models

class Site(models.Model):
    name = models.CharField(max_length=255)
    slug = models.SlugField(max_length=255)
    description = models.TextField(blank=True)
    url = models.URLField(max_length=2048, blank=True)

    rating_style = models.CharField(max_length=24, blank=True)
    rating_denominator = models.IntegerField(null=True)

    review_weight = models.IntegerField(null=True, default=1)

    logo  = models.ImageField(upload_to = 'images/critic_logos/', null=True, blank=True, help_text="Logos should be 43px x 43px.")
    large_logo = models.ImageField(upload_to = 'images/critic_logos/', null=True, blank=True, help_text="Logos should be 217px x 217px.")
    affiliate = models.BooleanField(default=False)
    link_copy = models.CharField(max_length=200, blank=True)

    def __unicode__(self):
        return self.name


class Author(models.Model):
    name = models.CharField(max_length=255)
    site = models.ForeignKey(Site)

    def __unicode__(self):
        return u'%s, %s' % (self.name, self.site)

    class Meta:
        unique_together = (
            ('name', 'site'),
        )
