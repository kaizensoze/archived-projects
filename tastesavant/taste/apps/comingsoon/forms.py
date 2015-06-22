from django import forms

from taste.apps.comingsoon.models import Email

class EmailForm(forms.ModelForm):
    class Meta:
        model = Email
