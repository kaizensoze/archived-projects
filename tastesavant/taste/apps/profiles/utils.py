"""
Utility functions for retrieving and generating forms for the
site-specific user profile model specified in the
``AUTH_PROFILE_MODULE`` setting.

"""
import facebook
import mailchimp
import twitter
import urlparse
from mailchimp.chimpy.chimpy import ChimpyException

from datetime import datetime
from django import forms
from django.conf import settings
from django.contrib.auth.models import SiteProfileNotAvailable, User
from django.contrib.sites.models import Site
from django.core.mail import EmailMultiAlternatives
from django.db.models import get_model, Count
from django.template import Context
from django.template.loader import get_template
from social_auth.models import UserSocialAuth

from taste.apps.newsfeed.utils import store_activity
from taste.apps.profiles.models import Profile
from taste.apps.profiles.socialables import GraphAPI, APIException
from taste.apps.profiles.synchronize import FourSquare
from taste.apps.restaurants.models import Location

def resolve_restaurant(checkins_list):
    matches = []
    restaurants = Location.objects.filter(foursquare_id__isnull=False)
    for r in restaurants:
        for ven_id, dt in checkins_list:
            if r.foursquare_id == ven_id:
                matches.append({'restaurant':r,'created':dt})
    return matches

def sync_foursquare_checkins(username):
    try:
        auth = UserSocialAuth.objects.get(user__username=username,
                                          provider='foursquare')
    except UserSocialAuth.DoesNotExist:
        return

    fs = FourSquare()
    uid = auth.uid
    oauth_token = auth.extra_data['access_token']

    checkins = fs.get_checkins(uid, oauth_token)
    venue_ids = fs.get_venue_id(checkins)
    results = resolve_restaurant(venue_ids)

    for res in results:
        store_activity(user=auth.user, action_name='foursquare',
                       metadata={'restaurant':res['restaurant'].restaurant.name},
                       occurred=res['created'])

    profile = auth.user.get_profile()
    profile.last_sync_foursquare = datetime.now()
    profile.save()

def get_profile_model():
    """
    Return the model class for the currently-active user profile
    model, as defined by the ``AUTH_PROFILE_MODULE`` setting. If that
    setting is missing, raise
    ``django.contrib.auth.models.SiteProfileNotAvailable``.

    """
    if (not hasattr(settings, 'AUTH_PROFILE_MODULE')) or \
           (not settings.AUTH_PROFILE_MODULE):
        raise SiteProfileNotAvailable
    profile_mod = get_model(*settings.AUTH_PROFILE_MODULE.split('.'))
    if profile_mod is None:
        raise SiteProfileNotAvailable
    return profile_mod


def get_profile_form():
    """
    Return a form class (a subclass of the default ``ModelForm``)
    suitable for creating/editing instances of the site-specific user
    profile model, as defined by the ``AUTH_PROFILE_MODULE``
    setting. If that setting is missing, raise
    ``django.contrib.auth.models.SiteProfileNotAvailable``.

    """
    profile_mod = get_profile_model()
    class _ProfileForm(forms.ModelForm):
        class Meta:
            model = profile_mod
            exclude = ('user',) # User will be filled in by the view.
    return _ProfileForm

def follow(user, friend):
    # @todo: This is some serious code duplication. This, the signal in
    # profiles.models, and profiles.views.follow need to be tightened up and
    # brought together as a method on the Profile model. --kit 2012-05-10
    profile = user.user.get_profile()
    following_user_profile = friend.user.get_profile()
    profile.add_friend(friend.user)

    current_site = Site.objects.get_current()
    domain = current_site.domain

    if friend.user.email:
        to = friend.user.email
        d = Context({"domain": domain, "follower": following_user_profile.get_truncated_name, "fullname" : profile.get_truncated_name, "following": following_user_profile.get_truncated_name, "follower_profile": following_user_profile.get_absolute_url})
        subject = get_template('newsfeed/follow_subject.txt').render(d)
        text_template = get_template('newsfeed/follow_content.txt')
        html_template = get_template('newsfeed/follow_content_html.txt')
        text_content = text_template.render(d)
        html_content = html_template.render(d)
        msg = EmailMultiAlternatives(subject, text_content, "hello@tastesavant.com", [to])
        msg.attach_alternative(html_content, "text/html")

def match_friends(user, all_users, friends):
    f = [friend['id'] for friend in friends]
    for u in all_users:
        if user is not u:
            if u.uid in f:
                follow(user, u)

def sync_facebook_friends():
    fb = GraphAPI()
    users = UserSocialAuth.objects.filter(provider='facebook')
    for u in users:
        fb.set_authorization(u.extra_data['access_token'], u.uid)
        try:
            friends = fb.get_friends()
            match_friends(u, users, friends)
        except APIException:
            pass


# Suggest friends utilities

FOLLOW_SUGGESTION_STOPLIST = (
    'AlanaAdmin',
    'EmmaAdmin',
    'LaurenAdmin',
    'MeganAdmin',
    'NicoleAdmin',
    'SheelaAdmin',
    'VictoriaAdmin',
    'AmandaAdmin',
    'root',
    'username',
    'CaitlynAdmin',
    'DanaAdmin',
    'KimberlyAdmin',
    'Noah',
    'sonia',
    'skap',
    'soniaj2',
    'odesk2',
)

def suggest_bloggers(user, limit=20):
    try:
        friends = user.get_profile().friends.all()
    except:
        return []
    bloggers = User.objects\
               .annotate(has_profile=Count('profile')).exclude(has_profile=0)\
               .exclude(is_staff=True)\
               .exclude(username__in=FOLLOW_SUGGESTION_STOPLIST)\
               .exclude(username__in=[user.username] + [u.username for u in friends])\
               .filter(profile__blogger=True)\
               .annotate(num_reviews=Count('review'))\
               .order_by('-num_reviews')
    return bloggers[:limit]

def suggest_most_active_users(user, limit=20):
    try:
        friends = user.get_profile().friends.all()
    except:
        return []
    most_active_users = User.objects\
                        .annotate(has_profile=Count('profile')).exclude(has_profile=0)\
                        .exclude(is_staff=True)\
                        .exclude(username__in=FOLLOW_SUGGESTION_STOPLIST)\
                        .exclude(username__in=[user.username] + [u.username for u in friends])\
                        .annotate(num_reviews=Count('review'))\
                        .order_by('-num_reviews')
    return most_active_users[:limit]

def suggest_reciprocal_friends(user, limit=20):
    try:
        friends = user.get_profile().friends.all()
    except:
        return []
    reciprocal_friends = User.objects\
                         .annotate(has_profile=Count('profile')).exclude(has_profile=0)\
                         .exclude(is_staff=True)\
                         .exclude(username__in=FOLLOW_SUGGESTION_STOPLIST)\
                         .filter(profile__friends=user)\
                         .exclude(username__in=[user.username] + [u.username for u in friends])\
                         .annotate(num_reviews=Count('review'))\
                         .order_by('-num_reviews')
    return reciprocal_friends[:limit]

def suggest_friends_of_friends(user, limit=20):
    try:
        friends = user.get_profile().friends.all()
    except:
        return []
    # This is brittle, but I don't know how to do it better.
    friends_of_friends = User.objects\
                         .annotate(has_profile=Count('profile')).exclude(has_profile=0)\
                         .exclude(is_staff=True)\
                         .exclude(username__in=FOLLOW_SUGGESTION_STOPLIST)\
                         .exclude(username__in=[user.username] + [u.username for u in friends])\
                         .filter(profile__friends__in=friends)\
                         .distinct()\
                         .annotate(num_reviews=Count('review'))\
                         .order_by('-num_reviews')
    return friends_of_friends[:limit]

# Mailchimp utilities

def is_subscribed_to_mailchimp(email, list_name):
    mailing_list = mailchimp.utils.get_connection().get_list_by_id(settings.MAILCHIMP_LISTS[list_name])
    return email in mailing_list.members

def send_welcome_email(user):
    print('sending welcome email')
    
    to = user.email
    username = user.username
    d = Context({
        "username" : username
    })
    subject = get_template('newsfeed/signup_subject.txt').render(d)
    text_template = get_template('newsfeed/signup_content.txt')
    html_template = get_template('newsfeed/signup_content_html.txt')
    text_content = text_template.render(d)
    html_content = html_template.render(d)
    msg = EmailMultiAlternatives(subject, text_content, "hello@tastesavant.com", [to])
    msg.attach_alternative(html_content, "text/html")
    msg.send()

def unsubscribe_from_mailchimp(user, list_name):
    email = user.email
    try:
        mailing_list = mailchimp.utils.get_connection().get_list_by_id(settings.MAILCHIMP_LISTS[list_name])
        mailing_list.unsubscribe(email)
    except ChimpyException:
        return

def subscribe_to_mailchimp(email, list_name, welcome=False, double_optin=False, mobile_city=None):
    # temporary stopgap for mobile signups defaulting to Boston due to inaccurate device location
    if mobile_city == "Boston":
        mobile_city = "New York"

    if isinstance(email, basestring):
        # Then we have just a raw email.
        first_name = None
        last_name = None
        user = None
    else:
        # Then we have a user object
        try:
            user = email
            email = user.email
            # Wish this was a method on users or profiles.
            first_name = user.first_name or user.get_profile().first_name
            last_name = user.last_name or user.get_profile().last_name
        except Profile.DoesNotExist:
            first_name = None
            last_name = None
    try:
        mailing_list = mailchimp.utils.get_connection().get_list_by_id(settings.MAILCHIMP_LISTS[list_name])

        data = {}

        # email
        data['EMAIL'] = email

        # first/last name
        if first_name is not None:
            data['FNAME'] = first_name
        if last_name is not None:
            data['LNAME'] = last_name

        # city
        interest_groups = mailing_list.interest_groups['groups']
        current_site = Site.objects.get_current()
        current_city = settings.CITIES[current_site.pk]

        if current_city in interest_groups or mobile_city:
            # make note of mobile if appropriate
            if mobile_city:
                city_label = "Mobile - %s" % mobile_city
            else:
                city_label = current_city

            data['GROUPINGS'] = {
                0: {
                    'name': 'City',
                    'groups': city_label,
                }
            }

        mailing_list.subscribe(email, data, double_optin=double_optin)

        print(user)
        print('subscribed to ' + list_name)
    except ChimpyException as e:
        print(e)
        return

def tweet_as_user(user, message):
    user_social_auths = UserSocialAuth.objects.filter(user=user,
        provider='twitter')
    for usa in user_social_auths:
        d = urlparse.parse_qs(usa.extra_data['access_token'])
        consumer_key = settings.TWITTER_CONSUMER_KEY
        consumer_secret = settings.TWITTER_CONSUMER_SECRET
        access_token = d['oauth_token'][0]
        access_token_secret = d['oauth_token_secret'][0]
        api = twitter.Api(consumer_key=consumer_key,
            consumer_secret=consumer_secret,
            access_token_key=access_token,
            access_token_secret=access_token_secret)
        try:
            api.VerifyCredentials()
        except twitter.TwitterError:
            continue
        api.PostUpdate(message)

def facebook_post_as_user(user, metadata):
    user_social_auths = UserSocialAuth.objects.filter(user=user,
        provider='facebook')
    for usa in user_social_auths:
        graph = facebook.GraphAPI(usa.extra_data['access_token'])
        attachment = {
            "name": "%(name)s" % metadata,
            "link": "%(site)s%(url)s" % metadata,
            "caption": "I posted a new review",
            "description": "I just reviewed %(name)s on Taste Savant." % metadata,
            "picture": "http://tastesavant.com/media/images/logo-main.png"
        }
        graph.put_wall_post("I just reviewed a thing.", attachment)
