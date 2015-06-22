from django import forms
from django.forms.widgets import CheckboxSelectMultiple

from taste.apps.restaurants.models import Neighborhood, Cuisine, Occasion

class ExtendedSearchForm(forms.Form):
    neighborhood = forms.ModelMultipleChoiceField(queryset=Neighborhood.objects.all(), widget=CheckboxSelectMultiple())
    cuisine = forms.ModelMultipleChoiceField(queryset=Cuisine.objects.all(), widget=CheckboxSelectMultiple())
    occasion = forms.ModelMultipleChoiceField(queryset=Occasion.objects.all(), widget=CheckboxSelectMultiple())
