from django.contrib.sites.managers import CurrentSiteManager
from django.contrib.sites.models import Site
from django.db import models


class RestaurantQuerySet(models.query.QuerySet):
    def with_distance_from(self, lat, lng, order_by=None):
        if lat is None or lng is None:
            kwargs = {
                'select': {'distance_in_miles': 'NULL'}
            }
        else:
            kwargs = {
                'select': {
                    'distance_in_miles': """SELECT ((6371 *
                (2 *
                    ATAN2(
                        SQRT(
                            SIN(
                                RADIANS(%s - `restaurants_location`.`lat`) /
                                2
                            ) * SIN(
                                RADIANS(%s - `restaurants_location`.`lat`) /
                                2
                            ) + SIN(
                                RADIANS(%s - `restaurants_location`.`lng`) /
                                2
                            ) * SIN(
                                RADIANS(%s - `restaurants_location`.`lng`) /
                                2
                            ) * COS(
                                RADIANS(`restaurants_location`.`lat`)
                            ) * COS(
                                RADIANS(%s)
                            )
                        ),
                        SQRT(
                            1 -
                            SIN(
                                RADIANS(%s - `restaurants_location`.`lat`) /
                                2
                            ) * SIN(
                                RADIANS(%s - `restaurants_location`.`lat`) /
                                2
                            ) + SIN(
                                RADIANS(%s - `restaurants_location`.`lng`) /
                                2
                            ) * SIN(
                                RADIANS(%s - `restaurants_location`.`lng`) /
                                2
                            ) * COS(
                                RADIANS(`restaurants_location`.`lat`)
                            ) * COS(
                                RADIANS(%s)
                            )
                        )
                    )
                )
            ) * 0.621371) as distance
    FROM `restaurants_restaurant` inner_restaurant
        INNER JOIN `restaurants_location`
        ON (`inner_restaurant`.`id` = `restaurants_location`.`restaurant_id`)
        WHERE `inner_restaurant`.`id` = `restaurants_restaurant`.`id`
        LIMIT 1
                """
                },
                'select_params': (
                    lat, lat, lng, lng, lat,
                    lat, lat, lng, lng, lat
                )
            }

        if order_by is not None:
            kwargs['order_by'] = order_by
        return self.extra(**kwargs)

    def with_friends_score_for(self, user):
        if user:
            return self.extra(
                select={
                    'friends_say': """SELECT
        AVG(`reviews_score`.`value`) AS `friends_say`
        FROM `reviews_score`
        INNER JOIN `reviews_review`
        ON (`reviews_score`.`id` = `reviews_review`.`score_id`)
        WHERE (
        `reviews_review`.`user_id` IN (
        SELECT
        U0.`id`
        FROM
        `auth_user` U0
        INNER JOIN `profiles_friendship` U1
        ON (U0.`id` = U1.`user_id`)
        WHERE U1.`profile_id` = %s )
        AND `reviews_review`.`restaurant_id` = `restaurants_restaurant`.`id`
        AND `reviews_review`.`active` = True )
        GROUP BY `reviews_review`.`restaurant_id`
        ORDER BY `friends_say` ASC
                    """
                },
                select_params=(user.get_profile().pk,)
            )
        else:
            return self.extra(
                select={'friends_say': "NULL"}
            )


# Via http://djangosnippets.org/snippets/562/
class DistanceAndFriendsMixin(object):
    def get_query_set(self):
        ret = RestaurantQuerySet(self.model)
        return ret

    def __getattr__(self, attr, *args):
        try:
            return getattr(self.__class__, attr, *args)
        except AttributeError:
            return getattr(self.get_query_set(), attr, *args)


class RestaurantSpecialQueriesManager(DistanceAndFriendsMixin, models.Manager):
    pass


class RestaurantCurrentSiteManager(DistanceAndFriendsMixin, models.Manager):
    def get_query_set(self):
        current_site = Site.objects.get_current()
        return super(
            RestaurantCurrentSiteManager,
            self
        ).get_query_set().filter(active=True, site=current_site)


class ActiveManager(models.Manager):

    # Note: do not change this to a CurrentSiteManager, as it gets used by
    # Reviews, too. Eugh.
    """
    Returns results that should be live on the site in decending order by
    published date.
    """

    def get_query_set(self):
        qs = super(ActiveManager, self).get_query_set()
        qs = qs.exclude(active=False)
        return qs


class LocatedManager(models.Manager):
    """
    If the lat/long is invalid  ... it's ignored
    """

    def get_query_set(self):
        qs = super(LocatedManager, self).get_query_set()
        qs = qs.exclude(lat=0, lng=0)
        return qs
