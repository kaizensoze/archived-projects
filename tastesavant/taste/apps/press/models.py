from django.db import models
from positions.fields import PositionField

from easy_thumbnails.fields import ThumbnailerImageField


class PressBadge(models.Model):
    image = ThumbnailerImageField(
        upload_to='images/press_logos/',
        resize_source=dict(size=(162, 100))
    )
    url = models.URLField()
    name = models.CharField(max_length=64)
    order = PositionField(default=0)

    class Meta:
        ordering = ('order',)

    def __unicode__(self):
        return self.name
