from django import forms
from taste.apps.restaurants.models import Occasion
from taste.apps.restaurants.widgets import CheckboxColumnSelectMultiple

class WriteReviewForm(forms.Form):
    overall_score = forms.IntegerField(
        min_value=0, max_value=10, initial=0,
        required=True, label='Overall',
        widget=forms.HiddenInput())
    
    food_score = forms.IntegerField(
        min_value=0, max_value=10, initial=0,
        required=True, label='Food',
        widget=forms.HiddenInput())
    
    ambience_score = forms.IntegerField(
        min_value=0, max_value=10, initial=0,
        required=True, label='Ambience',
        widget=forms.HiddenInput())
    
    service_score = forms.IntegerField(
        min_value=0, max_value=10, initial=0,
        required=True, label='Service',
        widget=forms.HiddenInput())
    
    review = forms.CharField(
        required=False,
        widget=forms.Textarea(attrs={'class':'lg'}))

    good_dishes = forms.CharField(
        label="Outstandingly good",
        required=False,
        widget=forms.Textarea(attrs={'class':'med'}))
    
    bad_dishes = forms.CharField(
        label="Outstandingly bad",
        required=False,
        widget=forms.Textarea(attrs={'class':'med'}))
    
    more_tips = forms.ModelMultipleChoiceField(
        required = False,
        help_text = 'Is this restaurant good for...',
        queryset=Occasion.objects.all(), 
        widget=CheckboxColumnSelectMultiple())

