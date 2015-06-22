from django.db import models

class Tag(models.Model):
    active = models.BooleanField()
    name = models.CharField(max_length = 255)
    html = models.TextField()
    
    def __unicode__(self):
        return self.name