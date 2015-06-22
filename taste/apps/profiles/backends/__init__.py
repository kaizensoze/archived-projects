from django.shortcuts import redirect

from social_auth.models import UserSocialAuth
from social_auth.backends.facebook import FacebookBackend
from social_auth.backends.twitter import TwitterBackend

from apps.profiles.models import (
    get_facebook_birthday,
    get_facebook_gender,
    get_facebook_name,
    get_facebook_image_url,
    set_avatar_from_url,
    get_twitter_image_url,
    HumanName,
)

from taste.apps.newsfeed.models import Activity
from taste.apps.profiles.models import Profile, Friendship
from taste.apps.reviews.models import Review


def social_auth_link(backend, uid, user=None, *args, **kwargs):
    """Return UserSocialAuth account for backend/uid pair or None if it
    doesn't exist.

    Associate the accounts if we're logged in.
    """
    social_user = UserSocialAuth.get_social_auth(backend.name, uid)
    if social_user:
        if user and social_user.user != user:
            # Then we are associating accounts.
            old_social_user = social_user.user
            # First, find everything associated with the social_user.
            activities = Activity.objects.filter(user=social_user.user)
            reviews = Review.objects.filter(user=social_user.user)
            # Then, associate it with the local user.
            for activity in activities:
                activity.user = user
                activity.save()
            for review in reviews:
                review.user = user
                review.save()
            # Iterate through to-and-from friendships, preserving notice-sent
            # time.
            from_friendships = Friendship.objects.filter(
                profile=old_social_user.get_profile()
            )
            for friendship in from_friendships:
                try:
                    Friendship.objects.get(
                        user=friendship.user,
                        profile=user.get_profile()
                    )
                except Friendship.DoesNotExist:
                    friendship.profile = user.get_profile()
                    friendship.save()
            to_friendships = Friendship.objects.filter(user=old_social_user)
            for friendship in to_friendships:
                try:
                    Friendship.objects.get(
                        user=user,
                        profile=friendship.profile
                    )
                except Friendship.DoesNotExist:
                    friendship.user = user
                    friendship.save()
            # Make sure you're not following yourself.
            user.get_profile().remove_friend(user)
            # Then nuke the old profile.
            profiles = Profile.objects.filter(user=old_social_user)
            for profile in profiles:
                profile.delete()
            # Then proceed on our merry way.
            # Delete the old user, too:
            old_social_user.delete()
            # Then link 'em up
            social_user.user = user
            social_user.save()
            return redirect('link_accounts')
        elif not user:
            user = social_user.user
    return {'social_user': social_user, 'user': user}


def get_user_avatar(
        backend,
        details,
        response,
        social_user,
        uid,
        user,
        *args,
        **kwargs
        ):
    if backend.__class__ == FacebookBackend:
        facebook_extra_values(response, user)
    elif backend.__class__ == TwitterBackend:
        twitter_extra_values(response, user)


def facebook_extra_values(response, user, *args, **kwargs):
    profile, created = Profile.objects.get_or_create(user=user)
    if not (profile.first_name and profile.last_name):
        profile = get_facebook_name(response, profile)
    if not profile.gender:
        profile = get_facebook_gender(response, profile)
    if not profile.birthday:
        profile = get_facebook_birthday(response, profile)
    profile.save()
    # set avatar
    url = get_facebook_image_url(response)
    set_avatar_from_url(user, url)
    return True


def twitter_extra_values(response, user, *args, **kwargs):
    name = user.first_name
    profile, created = Profile.objects.get_or_create(user=user)
    if len(name.split()) >= 2:
        name = HumanName(name)
        user.first_name = name.first
        user.last_name = name.last
        if not profile.first_name:
            profile.first_name = name.first
        if not profile.last_name:
            profile.last_name = name.last

    # double check, because we get data in here in bad ways:
    if not profile.first_name:
        profile.first_name = user.first_name
    if not profile.last_name:
        profile.last_name = user.last_name
    profile.save()
    # set the avatar
    url = get_twitter_image_url(response)
    set_avatar_from_url(user, url)
    return True
