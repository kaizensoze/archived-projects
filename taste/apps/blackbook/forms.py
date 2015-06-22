from django.forms import ModelForm

from .models import (
    Collection,
    Entry
)


class CollectionForm(ModelForm):
    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop('user', None)
        super(CollectionForm, self).__init__(*args, **kwargs)

    def save(self, commit=True):
        instance = super(CollectionForm, self).save(commit=False)
        if self.user:
            instance.user = self.user
        return instance.save()

    class Meta:
        model = Collection
        exclude = ('created', 'user')


class EntryForm(ModelForm):
    def __init__(self, *args, **kwargs):
        self.collection = kwargs.pop('collection', None)
        super(EntryForm, self).__init__(*args, **kwargs)

    def save(self, commit=True):
        instance = super(EntryForm, self).save(commit=False)
        if self.collection:
            instance.collection = self.collection
            instance.save()
        return instance.pk

    class Meta:
        model = Entry
        exclude = ('created', 'updated', 'restaurant', 'collection',)
