from datetime import datetime, timedelta
from django.conf import settings
from django.db.models import Q
from django.utils.timezone import now
from django.core.exceptions import ObjectDoesNotExist
from social_auth.models import UserSocialAuth
from taste.apps.newsfeed.models import Activity, Action
from taste.apps.profiles.socialables import Foursquare, GraphAPI, APIException
from taste.apps.restaurants.models import Location
from twitter import Twitter, OAuth
from time import sleep
import requests


class FriendManager(GraphAPI):
    def __init__(self):
        self.users = self.associated_users

    @property
    def associated_users(self):
        """Get all users that have their account associated with Facebook"""
        return UserSocialAuth.objects.filter(provider='facebook')

    def synchronize_all(self):
        for social_auth in self.associated_users:
            try:
                self.set_authorization(social_auth)
            except APIException:
                pass

    def synchronize_user(self, user):
        ttl = 5
        while True:
            social_auth = UserSocialAuth.objects.get(
                user=user,
                provider='facebook'
            )
            if social_auth is None or social_auth.extra_data is None:
                if ttl > 0:
                    ttl = ttl-1
                    sleep(2)
                else:
                    break
            else:
                break
        if ttl:
            self.set_authorization(social_auth)

    def update_last_synchronized(self):
        """Update the last synchronization to current datetime"""
        self.profile.last_sync_facebook = now()
        self.profile.save()

    def set_authorization(self, social_auth):
        """Set all user details and authorization parameters"""
        self.social_auth = social_auth
        self.user = self.social_auth.user
        try:
            self.access_token = self.social_auth.extra_data['access_token']
        except KeyError:
            # We shouldn't end up here, but if we do, bail.
            return
        self.client_id = self.social_auth.uid
        self.profile = self.user.get_profile()

        try:
            difference = now() - self.profile.last_sync_facebook
        except:
            difference = timedelta.max

        # print(now(), self.profile.last_sync_facebook)

        if difference >= timedelta(hours=24):
            # print('processing facebook friends')
            self._process()

    def _process(self):
        friends = self.get_friends()
        self.auto_connect(friends)
        self.update_last_synchronized()

    def get_friends(self):
        friends = super(FriendManager, self).get_friends()
        if friends:
            return [friend['id'] for friend in friends]
        else:
            return []

    def auto_connect(self, friends):
        already_friends = self.user.get_profile().friends.all()
        excludes = Q(user=self.user) | Q(user_id__in=already_friends)
        for user in self.users.filter(uid__in=friends).exclude(excludes):
            self.profile.add_friend(user.user)
            # Mutual-adding:
            user.user.get_profile().add_friend(self.user)


class CheckInManager(Foursquare):
    def __init__(self):
        self.restaurants = self.associated_restaurants
        self.ignore_timestamp = False

    def refresh_all(self):
        """Ignores timestamp in user profile."""
        self.ignore_timestamp = True

    @property
    def associated_users(self):
        """Get all users that have their account associated with Foursquare"""
        return UserSocialAuth.objects.filter(provider='foursquare')

    @property
    def associated_restaurants(self):
        """Get all restaurants that have a Foursquare venue ID"""
        return Location.objects.filter(foursquare_id__isnull=False)

    @property
    def latest_checkins(self):
        """Get all check-ins since last synchronization"""
        return self.get_checkins(after_timestamp=self.synchronized)

    def set_authorization(self, social_auth):
        """Set all user details and authorization parameters"""
        self.social_auth = social_auth
        self.user = self.social_auth.user
        self.access_token = self.social_auth.extra_data['access_token']
        self.client_id = self.social_auth.uid
        self.profile = self.user.get_profile()
        if self.ignore_timestamp:
            self.synchronized = None
        else:
            self.synchronized = self.profile.last_sync_foursquare

        self._process()

    def update_last_synchronized(self):
        """Update the last synchronization to current datetime"""
        self.profile.last_sync_foursquare = now()
        self.profile.save()

    def synchronize_user(self, user):
        try:
            social_auth = UserSocialAuth.objects.get(user=user,
                                                     provider='foursquare')
            self.set_authorization(social_auth)
        except UserSocialAuth.DoesNotExist:
            pass

    def synchronize_all(self):
        for social_auth in self.associated_users:
            try:
                self.set_authorization(social_auth)
            except APIException:
                pass

    def _process(self):
        checkins = self.latest_checkins
        if not checkins:
            return
        for r in self.restaurants:
            found, data = self.intersection(r.foursquare_id, checkins)
            if found:
                self.announce(r, data)
        self.update_last_synchronized()

    def intersection(self, foursquare_id, check_ins):
        for data in check_ins:
            try:
                if foursquare_id == data['venue']['id']:
                    return (True, data)
            except KeyError:
                pass
        return (False, None)

    def announce(self, restaurant_location, check_in):
        to_datetime = lambda ts: datetime.fromtimestamp(ts)
        occurred = to_datetime(check_in['createdAt'])
        action = Action.objects.get(action_name='checkin')
        cross_street = None
        address = None
        try:
            cross_street = check_in['venue']['location']['crossStreet']
        except:
            pass
        try:
            address = check_in['venue']['location']['address']
        except:
            pass

        metadata = {
            'name': check_in['venue']['name'],
            'id': check_in['id'],
            'cross_street': cross_street,
            'address':  address,
            'url': restaurant_location.restaurant.get_absolute_url(),
            'original': check_in
            }

        Activity.objects.create(user=self.user, action=action,
                                meta_data=metadata, occurred=occurred,
                                restaurant=restaurant_location.restaurant)


class TwitterFollowingManager(object):
    """
    Twitter makes followers public, so this is simpler than the others.
    """
    class TwitterError(Exception):
        pass

    @classmethod
    def associated_users(cls):
        """Get all users that have their account associated with Twitter"""
        return UserSocialAuth.objects.filter(provider='twitter')

    @classmethod
    def synchronize_user(cls, user):
        twitter_usa = UserSocialAuth.objects.get(
            user=user,
            provider='twitter'
        )
        if 'access_token' not in twitter_usa.extra_data:
            # Then we're not ready. Return.
            return
        # Render the OAuth details into a Python dict.
        details = dict(
            map(
                lambda x: x.split('='),
                twitter_usa.extra_data['access_token'].split('&')
            )
        )
        t = Twitter(
            auth=OAuth(
                details['oauth_token'],
                details['oauth_token_secret'],
                settings.TWITTER_CONSUMER_KEY,
                settings.TWITTER_CONSUMER_SECRET
            )
        )
        followees = t.friends.ids(stringify_ids=True)['ids']
        matching_local_users = cls.get_matching_local_users(followees)
        cls.auto_connect(user, matching_local_users)

    @classmethod
    def synchronize_all(cls):
        for social_auth in cls.associated_users():
            cls.synchronize_user(social_auth.user)

    @classmethod
    def get_matching_local_users(cls, twitter_followees):
        return [u.user for u in UserSocialAuth.objects.filter(
            uid__in=twitter_followees
        )]

    @classmethod
    def auto_connect(cls, user, followees):
        """Since Twitter doesn't presume mutual-connection,
        neither will we. This connects in just one direction."""
        try:
            user.get_profile()
        except ObjectDoesNotExist:
            return
        for followee in followees:
            user.get_profile().add_friend(followee)
