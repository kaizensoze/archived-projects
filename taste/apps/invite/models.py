from django.db import models
from django.contrib.auth.models import User

class Contact(models.Model):
    # the user who created the contact
    user = models.ForeignKey(User, related_name="contacts")
    
    name = models.CharField(max_length=100, null=True, blank=True)
    email = models.EmailField()
    added = models.DateField(auto_now=True, editable=False)
    provider = models.CharField(max_length=100, null=True, blank=True)
    # the user(s) this contact correspond to
    users = models.ManyToManyField(User)
    
    def __unicode__(self):
        return "%s (%s's contact)" % (self.email, self.user)
