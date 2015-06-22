from haystack.indexes import SearchIndex, CharField, Indexable
from django.contrib.auth.models import User

from .utils import FOLLOW_SUGGESTION_STOPLIST


class UserIndex(SearchIndex, Indexable):
    text = CharField(document=True, use_template=True)
    username = CharField(model_attr='username')
    first_name = CharField(model_attr='first_name')
    last_name = CharField(model_attr='last_name')

    def index_queryset(self, *args, **kwargs):
        return User.objects.filter(
            is_superuser=False,
            is_staff=False
        ).exclude(
            username__in=FOLLOW_SUGGESTION_STOPLIST
        )

    def get_model(self):
        return User
