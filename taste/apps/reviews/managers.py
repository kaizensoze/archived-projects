from taste.apps.restaurants.managers import ActiveManager
from django.db import models


class ReviewQuerySet(models.query.QuerySet):
    def with_special_sort_key(self):
        kwargs = {
            'select': {
                'special_sort_key': """
                    CASE
                    WHEN `reviews_review`.`user_id` is NULL
                    THEN `reviews_review`.`published`
                    ELSE `reviews_review`.`published`
                    END
                """
            }
        }
        return self.extra(**kwargs)


# Via http://djangosnippets.org/snippets/562/
class ReviewQuerySetMixin(object):
    def get_query_set(self):
        ret = ReviewQuerySet(self.model)
        ret = ret.exclude(active=False)
        return ret

    def __getattr__(self, attr, *args):
        try:
            return getattr(self.__class__, attr, *args)
        except AttributeError:
            return getattr(self.get_query_set(), attr, *args)


class ReviewManager(ReviewQuerySetMixin, ActiveManager):
    pass
