from haystack.indexes import (
    SearchIndex,
    CharField,
    DecimalField,
    FacetCharField,
    Indexable
)
from taste.apps.restaurants.models import Restaurant


class RestaurantIndex(SearchIndex, Indexable):
    text = CharField(document=True, use_template=True)

    name = CharField(model_attr='name')
    site = CharField(model_attr='site__domain')
    savants_say = DecimalField(model_attr='savants_say', default=0)
    critics_say = DecimalField(model_attr='critics_say', default=0)
    suggestions = FacetCharField()

    def index_queryset(self, *args, **kwargs):
        return Restaurant.objects.filter(active=True)

    def prepare(self, obj):
        prepared_data = super(RestaurantIndex, self).prepare(obj)
        prepared_data['suggestions'] = prepared_data['text']
        return prepared_data

    def get_model(self):
        return Restaurant
