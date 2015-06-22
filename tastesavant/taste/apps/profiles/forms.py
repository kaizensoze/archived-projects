from django import forms
from django.contrib.auth.models import User
from taste.apps.profiles.models import Profile

class ProfileForm(forms.ModelForm):

    def __init__(self, *args, **kwargs):
        super(ProfileForm, self).__init__(*args, **kwargs)
        try:
            self.fields['email'].initial = self.instance.user.email
        except User.DoesNotExist:
            pass

    first_name = forms.CharField(required=True)
    last_name = forms.CharField(required=True)
    email = forms.EmailField(label="Email", required=True)
    type_expert = forms.CharField(required=False, max_length=32)
    favorite_food = forms.CharField(required=False, max_length=32)
    favorite_restaurant = forms.CharField(required=False, max_length=32)

    class Meta:
        model = Profile
        fields = ('first_name', 'last_name', 'gender', 'birthday',
                  'zipcode', 'type_expert', 'type_reviewer', 'favorite_food',
                  'favorite_restaurant','location', 'notification_level')
        exclude = ('friends','view_count', 'last_sync_foursquare','last_sync_facebook')
        widgets = {
            'birthday': forms.DateInput(format='%m-%d-%Y'),
        }

    def save(self, *args, **kwargs):
        u = self.instance.user
        u.email = self.cleaned_data['email']
        u.save()
        profile = super(ProfileForm, self).save(*args, **kwargs)
        return profile
