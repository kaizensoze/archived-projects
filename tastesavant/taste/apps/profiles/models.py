import re

from avatar.models import Avatar, create_default_thumbnails
from datetime import datetime
from django.conf import settings
from django.contrib.auth.models import User
from django.contrib.sites.models import Site
from django.core.exceptions import ObjectDoesNotExist
from django.core.files import File
from django.core.files.temp import NamedTemporaryFile
from django.core.urlresolvers import reverse
from django.db import models
from django.db.models.signals import post_save
from django.utils.translation import ugettext as _
from nameparser import HumanName
from social_auth.backends.contrib.foursquare import FoursquareBackend
from social_auth.backends.facebook import FacebookBackend
from social_auth.backends.twitter import TwitterBackend
from social_auth.models import UserSocialAuth
from social_auth.signals import pre_update
from taste.apps.newsfeed.models import Activity, Action
from taste.apps.profiles.middleware import FriendManager, TwitterFollowingManager
from taste.apps.profiles.tasks import send_friendship_email
# Is this going to make a circular dependency?
from taste.apps.reviews.models import Review

from urlparse import urlparse
import urllib
import urllib2
import twitter

REVIEWER_CHOICES = (
    ('easily_pleased', u'Easily Pleased'),
    ('middle_of_the_road', u'Middle of the Road'),
    ('discerning_diner', u'Discerning Diner'),
)

GENDER_CHOICES = (
    ('M', u'Male'),
    ('F', u'Female'),
)

NOTIFICATION_LEVEL_CHOICES = (
    ('instant', u'Receive notifications as they come'),
    ('digest', u'Receive notifications once a day'),
    ('none', u'Receive no email notifications'),
)


class Profile(models.Model):
    """ User profile """

    user = models.OneToOneField(User)
    first_name = models.CharField(blank=True, max_length=255)
    last_name = models.CharField(blank=True, max_length=255)
    gender = models.CharField(blank=True, null=True, max_length=2,
        verbose_name="Gender", choices=GENDER_CHOICES)
    location = models.CharField(blank=True, null=True, max_length=255,
        verbose_name="""Where do you live? (i.e., San Francisco, Manhattan,
        SoHo)""")
    birthday = models.DateField(null=True, blank=True)
    zipcode = models.CharField(blank=True, max_length=10)
    type_expert = models.CharField(blank=True, max_length=255,
        verbose_name="What type of food are you an expert in?")
    type_reviewer = models.CharField(blank=True, max_length=255,
        verbose_name="How tough of a reviewer are you?",
        choices=REVIEWER_CHOICES)
    favorite_food = models.CharField(blank=True, max_length=255,
        verbose_name="""What is your favorite food?""")
    favorite_restaurant = models.CharField(blank=True, max_length=255,
        verbose_name="""What is your favorite restaurant?""")
    view_count = models.PositiveIntegerField(default=0, editable=False)
    friends = models.ManyToManyField(User, blank=True, null=True,
        related_name="friends", through='Friendship')
    last_sync_foursquare = models.DateTimeField(null=True, blank=True)
    last_sync_facebook = models.DateTimeField(null=True, blank=True)
    blogger = models.BooleanField(default=False)
    notification_level = models.CharField(max_length=16, default='instant',
        verbose_name="""How often would you like to be notified that you have new followers on Taste Savant?""",
        choices=NOTIFICATION_LEVEL_CHOICES)
    digest_notifications = models.CharField(max_length=255, default='', blank=True)
    preferred_site = models.ForeignKey(Site)
    signed_up_via_app = models.BooleanField("Mobile activity", default=False)

    @property
    def is_valid(self):
        """This evaluates to True if the Profile or User has a first name, and
        the Profile or User has a last name, and the User has an email"""

        return bool((self.first_name or self.user.first_name) and
            (self.last_name or self.user.last_name) and
            self.user.email)

    @property
    def avatar(self):
        if self.user.avatar_set.count():
            return self.user.avatar_set.get(primary=True)
        return None

    @property
    def city_tag(self):
        return re.sub(r'(Taste Savant ?)?(.*)', r'\2', self.preferred_site.name)

    @property
    def total_review_count(self):
        return Review.objects.filter(
            active=True,
            restaurant__active=True
        ).exclude(
            restaurant__site__name__in=settings.API_PRIVATE_CITIES
        ).filter(
            user=self.user
        ).count()

    @property
    def reviews_on_current_site(self):
        current_site = Site.objects.get_current()
        return Review.objects.filter(restaurant__site=current_site).count()

    @property
    def _get_api_url(self):
        # @todo: the protocol should be https.
        uri_root = "http://" + Site.objects.get_current().domain
        return uri_root + reverse('api-user-instance',
            kwargs={'slug': self.user.username})

    @property
    def _follow(self):
        return self._get_api_url + 'follow/'

    @property
    def _unfollow(self):
        return self._get_api_url + 'unfollow/'

    @property
    def _following(self):
        return self._get_api_url + 'following/'

    @property
    def _followers(self):
        return self._get_api_url + 'followers/'

    @property
    def _feed(self):
        return self._get_api_url + 'feed/'

    @property
    def _friendsfeed(self):
        return self._get_api_url + 'friendsfeed/'

    @property
    def _reviews(self):
        return self._get_api_url + 'reviews/'

    @property
    def _suggestions(self):
        return self._get_api_url + 'suggestions/'

    def add_friend(self, user):
        try:
            friendship = Friendship.objects.get(user=user, profile=self)
        except Friendship.DoesNotExist:
            friendship = Friendship(
                user=user,
                profile=self
            )
            friendship.save()

    def remove_friend(self, user):
        try:
            friendship = Friendship.objects.get(user=user, profile=self)
        except Friendship.DoesNotExist:
            return
        friendship.delete()

    def get_truncated_name(self):
        if self.last_name:
            return '%s %s.' % (self.first_name, self.last_name[0:1])
        elif self.user.first_name.strip() and self.user.last_name.strip():
            return '%s %s.' % (self.user.first_name, self.user.last_name[0:1])
        else:
            return self.user.username

    def __unicode__(self):
        return self.first_name + self.last_name

    @models.permalink
    def get_absolute_url(self):
        return ('profiles_profile_detail', None,
            {'username': self.user.username})

    class Meta:
        verbose_name = _('profile')
        verbose_name_plural = _('profiles')


class Friendship(models.Model):
    profile = models.ForeignKey(Profile)
    user = models.ForeignKey(User)
    notice_sent_to_user_at = models.DateTimeField(null=True, blank=True)


def set_avatar_from_url(user, url):
    if not url:
        return
    http_response = urllib2.urlopen(url)
    if http_response.getcode() != 200:
        return
    file_name = urlparse(http_response.geturl()).path.split('/')[-1]

    image_dump = http_response.read()
    image_temp = NamedTemporaryFile(delete=True)
    image_temp.write(image_dump)
    image_temp.flush()

    avatar = Avatar()
    avatar.user_id = user.id
    avatar.primary = True
    avatar.avatar.save(file_name, File(image_temp))
    avatar.save()
    create_default_thumbnails(None, instance=avatar, created=True)


def get_twitter_image_url(response):
    elements = [x.split('=') for x in response['access_token'].split('&')]
    # If something is not shaped right in the access_token, we need to bail:
    if not all(map(lambda x: len(x) == 2, elements)):
        return ''
    token_params = dict(elements)

    params = {
        'user_id': response['id'],
    }

    # Create your consumer with the proper key/secret.

    CONSUMER_KEY = settings.TWITTER_CONSUMER_KEY
    CONSUMER_SECRET = settings.TWITTER_CONSUMER_SECRET
    OAUTH_TOKEN = token_params['oauth_token']
    OAUTH_SECRET = token_params['oauth_token_secret']

    t = twitter.Twitter(
        auth=twitter.OAuth(
            OAUTH_TOKEN,
            OAUTH_SECRET,
            CONSUMER_KEY,
            CONSUMER_SECRET
        )
    )

    try:
        return t.users.show(**params)['profile_image_url'].replace(
            'normal',
            'bigger'
        )
    except:  # Let's just catch everything.
        return ''


def get_facebook_image_url(response):
    BASE_IMAGE_URL = "http://graph.facebook.com/%(id)s/picture?type=large"

    fid = response.get('id', None)
    if fid:
        return BASE_IMAGE_URL % {'id': fid}
    else:
        return None


def get_facebook_gender(response, prof):
    try:
        gender = response.get('gender').title()[:1]
        if gender in ['M', 'F']:
            prof.gender = gender
    except:
        pass
    return prof


def get_facebook_name(response, prof):
    prof.first_name = response.get('first_name', '')
    prof.last_name = response.get('last_name', '')
    return prof


def get_facebook_location(response, prof):
    try:
        location = response['location']['name']
        if len(location.split(',')) >= 2:
            prof.location = location.split(',')[0]
        else:
            prof.location = location
    except:
        pass
    return prof


def get_facebook_birthday(response, prof):
    try:
        birthday = response.get('birthday')
        prof.birthday = datetime.strptime(birthday, '%m/%d/%Y')
    except:
        pass
    return prof


def facebook_friends_add(sender, instance, **kwargs):
    if instance.provider != 'facebook':
        return
    # We call this task synchronously so that users who log in via Facebook
    # are immediately shown a list of people they're following. If we do it
    # asynchronously, there's latency between creating an account and
    # following your Facebook friends. That's no good!
    if instance.extra_data is None:
        # The UserSocialAuth model isn't ready yet, so continue.
        return
    try:
        instance.user.get_profile()
    except:
        return
    f_mgr = FriendManager()
    f_mgr.synchronize_user(instance.user)


def twitter_followees_add(sender, instance, **kwargs):
    if instance.provider != 'twitter':
        return
    # We call this task synchronously so that users who log in via Twitter
    # are immediately shown a list of people they're following. If we do it
    # asynchronously, there's latency between creating an account and
    # following your Twitter followees. That's no good!
    if instance.extra_data is None:
        # The UserSocialAuth model isn't ready yet, so continue.
        return
    # It is possible that this gets called before the user's profile has been
    # created. In that case, we can just create it here, and let the following
    # work.
    try:
        instance.user.get_profile()
    except ObjectDoesNotExist:
        if instance.user.is_authenticated():
            Profile.objects.create(user=instance.user)
    TwitterFollowingManager.synchronize_user(instance.user)


def new_follower(sender, instance, **kwargs):
    #TODO: triggers if profile gets updated in admin
    #
    # I think that this logic might fit better in a method on profiles; it
    # would allow greater control. This signal is sent from more places than
    # we want, without clear distinctions. --kit 2012-05-10
    #
    # This check makes sure that the email only goes out once per addition,
    # and not at all per removal.
    user = instance.profile.user
    followed_user = instance.user

    try:
        name = followed_user.get_profile().get_truncated_name()
        url = followed_user.get_profile().get_absolute_url()
    except Profile.DoesNotExist:
        name = followed_user.username
        url = reverse(
            'profiles_profile_detail',
            kwargs={'username': followed_user.username}
        )

    occurred = datetime.now()
    action = Action.objects.get(action_name='follow')

    metadata = {'name': name, 'url': url}

    Activity.objects.create(user=user, action=action,
                            meta_data=metadata, occurred=occurred)
    if followed_user.email:
        send_friendship_email(followed_user, user)

post_save.connect(facebook_friends_add, sender=UserSocialAuth,
    dispatch_uid="FacebookBackend.facebook_friends_add")
post_save.connect(twitter_followees_add, sender=UserSocialAuth,
    dispatch_uid="TwitterBackend.twitter_followees_add")
post_save.connect(new_follower, sender=Profile.friends.through,
    dispatch_uid="m2m.new_follower")

# Register a callback function to create a user profile if none present.
def create_or_save_user_profile(sender, instance, created, **kwargs):
    if created:
        site = Site.objects.get_current()
        Profile.objects.create(user=instance, preferred_site=site)

post_save.connect(create_or_save_user_profile, sender=User,
    dispatch_uid='create_or_save_user_profile')
