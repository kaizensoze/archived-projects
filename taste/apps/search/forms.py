from django import forms
from django.contrib.sites.models import Site
from django.db.models import Q
from django.forms.widgets import CheckboxSelectMultiple
from taste.apps.restaurants.widgets import (
    CheckboxSelectMultipleTree,
    CheckboxColumnSelectMultiple
)
from taste.apps.restaurants.models import (
    Neighborhood,
    Cuisine,
    Occasion,
    Price
)


class SearchForm(forms.Form):
    q = forms.CharField(initial="Restaurants, Keywords")


class ExtendedSearchForm(forms.Form):

    def __init__(self, *args, **kwargs):
        self.current_site = kwargs.pop(
            'current_site',
            Site.objects.get_current()
        )
        ret = super(ExtendedSearchForm, self).__init__(*args, **kwargs)
        # Load these on form initialization, not class definition.
        self.fields['neighborhood'].queryset = Neighborhood.objects.filter(
            borough__site=self.current_site,
            level__gt=0
        )
        self.fields['cuisine'].queryset = Cuisine.objects.filter(
            level__gt=0
        )
        self.fields['occasion'].queryset = Occasion.objects.filter(
            site=self.current_site,
            active=True
        )
        self.fields['price'].queryset = Price.objects.all()
        return ret

    current_site = Site.objects.get_current()

    neighborhood = forms.ModelMultipleChoiceField(
        required=False,
        queryset=Neighborhood.objects.filter(
            borough__site=current_site
        ),
        widget=CheckboxSelectMultipleTree()
    )

    cuisine = forms.ModelMultipleChoiceField(
        required=False,
        queryset=Cuisine.objects.all(),
        widget=CheckboxSelectMultipleTree()
    )

    occasion = forms.ModelMultipleChoiceField(
        required=False,
        queryset=Occasion.objects.all(),
        widget=CheckboxColumnSelectMultiple()
    )

    price = forms.ModelMultipleChoiceField(
        required=False,
        queryset=Price.objects.all(),
        widget=CheckboxSelectMultiple()
    )
