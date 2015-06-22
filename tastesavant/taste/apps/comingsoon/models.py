from django.db import models
from django.forms import ModelForm

class Email(models.Model):
    address = models.EmailField(max_length=320)

    def __unicode__(self):
        return self.address

class EmailForm(ModelForm):
    class Meta:
        model = Email
