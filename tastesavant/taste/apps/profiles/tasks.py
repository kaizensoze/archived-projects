from celery.task import task
from datetime import datetime
from taste.apps.profiles.middleware import (FriendManager, CheckInManager,
    TwitterFollowingManager)
from django.db.models import signals
from django.conf import settings
from django.contrib.auth.models import User
from django.contrib.sites.models import Site
from django.core.exceptions import ObjectDoesNotExist
from django_messages.models import Message
from django_messages.utils import new_message_email
from django.template.loader import get_template
from django.template import Context
from django.core.mail import EmailMultiAlternatives
from django.core.urlresolvers import reverse
import textwrap

def construct_email(to, frm, digest=None):
    to_profile = to.get_profile()
    if frm is not None:
        frm_profile = frm.get_profile()
    else:
        frm_profile = None
    current_site = Site.objects.get_current()
    domain = current_site.domain

    d = Context({
        "domain": domain,
        "fullname": to_profile.get_truncated_name,
    })

    if frm_profile is not None:
        d['follower'] = frm_profile.get_truncated_name
        d['following'] = frm_profile.get_truncated_name
        d['follower_profile'] = frm_profile.get_absolute_url
        d['edit_profile_link'] = "http://www.tastesavant.com" + reverse("profiles_edit_profile")
    if digest is not None:
        d['digest'] = digest

    subject = get_template('newsfeed/follow_subject.txt').render(d)
    text_template = get_template('newsfeed/follow_content.txt')
    html_template = get_template('newsfeed/follow_content_html.txt')
    text_content = text_template.render(d)
    html_content = html_template.render(d)
    msg = EmailMultiAlternatives(subject, text_content,
        "hello@tastesavant.com", [to.email])
    msg.attach_alternative(html_content, "text/html")
    return msg


@task(ignore_result=True)
def send_friendship_email(to, frm):
    from taste.apps.profiles.models import Friendship
    try:
        friendship = Friendship.objects.get(user=to, profile=frm.get_profile())
        if friendship.notice_sent_to_user_at is None:
            friendship.notice_sent_to_user_at = datetime.now()
            friendship.save()
        else:
            return
    except Friendship.DoesNotExist:
        pass
    notification_level = to.get_profile().notification_level
    if notification_level == 'instant':
        msg = construct_email(to, frm)
        msg.send()
    if notification_level == 'digest':
        # Profiles track the day's digest message, and then another task sends
        # and clears the digest.
        profile = to.get_profile()
        if profile.digest_notifications:
            profile.digest_notifications += "\n\n%s" % frm.username
        else:
            profile.digest_notifications = "%s" % frm.username
        profile.save()
    # If they have "none" or any of the other options, also send a TS message,
    # from the new follower
    #
    # Because messages "helpfully" sends an email notification whenever
    # you receive a message, we have to manually disconnect the signal,
    # send the message, reconnect it. I am worried this will cause
    # erratic loss of email notification of other messages, but we can
    # adjust it if we find that happening. -kit 2012-07-30
    signals.post_save.disconnect(new_message_email, sender=Message)
    ts_msg = Message(
        recipient=to,
        sender=frm,
        subject='%s is now following you!' % frm.username,
        body=textwrap.dedent(
            """Congrats, %(user)s is now following you on Taste Savant. If you
            want to check out their profile and follow them back, visit their
            profile <a href="%(link)s">here</a>.

            Enjoy!

            We now have an iPhone app! To check out restaurants nearby, reservations,
            reviews and menus on the go <a href="https://itunes.apple.com/us/app/taste-savant/id828925581?mt=8">download it here</a>.

            The Taste Savant Team""" % {"user": frm.username,
                "link": reverse('profiles_profile_detail',
                    kwargs={"username": frm.username})})
        )
    ts_msg.save()
    signals.post_save.connect(new_message_email, sender=Message)
    return

@task(ignore_result=True)
def send_digest_email(user):
    try:
        profile = user.get_profile()
    except ObjectDoesNotExist:
        return
    digest_notifications = profile.digest_notifications
    if digest_notifications:
        profile.digest_notifications = ''
        profile.save()
        digest = set(digest_notifications.split("\n\n"))
        msg = construct_email(user, None, digest)
        msg.send()


@task(ignore_result=True)
def send_digest_emails():
    for user in User.objects.all():
        send_digest_email(user)

@task(ignore_result=True)
def sync_foursquare():
    c_mgr = CheckInManager()
    c_mgr.synchronize_all()

@task(ignore_result=True)
def full_resync_foursquare():
    c_mgr = CheckInManager()
    c_mgr.refresh_all()
    c_mgr.synchronize_all()

@task(ignore_result=True)
def sync_friends():
    f_mgr = FriendManager()
    f_mgr.synchronize_all()

@task(ignore_result=True)
def sync_user_foursquare(user):
    c_mgr = CheckInManager()
    c_mgr.synchronize_user(user)

@task(ignore_result=True)
def sync_user_friends(user):
    f_mgr = FriendManager()
    f_mgr.synchronize_user(user)

@task(ignore_result=True)
def sync_twitter_followees():
    TwitterFollowingManager.synchronize_all()
