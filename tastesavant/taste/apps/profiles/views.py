from avatar.forms import UploadAvatarForm
from avatar.models import Avatar

from django.db.models import F
from django.contrib import messages
from django.contrib.auth import logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.contrib.sites.models import Site
from django.core.exceptions import ObjectDoesNotExist
from django.core.urlresolvers import reverse
from django.http import Http404, HttpResponseRedirect, HttpResponse
from django.shortcuts import get_object_or_404, render_to_response
from django.template import RequestContext
from django.views.generic.list_detail import object_list

from django_messages.forms import ComposeForm
from pure_pagination import Paginator, InvalidPage, EmptyPage
from social_auth.models import UserSocialAuth

from taste.apps.profiles import utils
from taste.apps.profiles.forms import ProfileForm
from taste.apps.profiles.models import Profile
from taste.apps.reviews.models import Review
from taste.apps.profiles.utils import (suggest_bloggers, suggest_most_active_users,
    suggest_reciprocal_friends, suggest_friends_of_friends, subscribe_to_mailchimp,
    unsubscribe_from_mailchimp, is_subscribed_to_mailchimp)

# @todo: Possibly clean these up a bit, decompose into smaller well-named
# functions.

def create_profile(request, form_class=None, success_url=None,
                   template_name='profiles/create_profile.html',
                   extra_context=None):
    try:
        request.user.get_profile()
    except ObjectDoesNotExist:
        if request.user.is_authenticated():
            # This path happens if you log in through FB or Twitter
            site = Site.objects.get_current()
            Profile.objects.create(user=request.user, preferred_site=site)
        else:
            raise Http404
    if request.user.email and not is_subscribed_to_mailchimp(request.user.email, 'User Sign Ups'):
        subscribe_to_mailchimp(request.user, 'User Sign Ups')
    return HttpResponseRedirect(reverse('follower_suggestions'))

def edit_avatar(request, upload_form=UploadAvatarForm):
    upload_avatar_form = upload_form(request.POST or None,
        request.FILES or None, user=request.user)
    if request.method == "POST" and 'avatar' in request.FILES:
        if upload_avatar_form.is_valid():
            avatar = Avatar(user = request.user, primary = True,)
            image_file = request.FILES['avatar']
            avatar.avatar.save(image_file.name, image_file)
            avatar.save()
            messages.success(request, 'Your profile picture has been changed.')
            success_url = reverse('profiles_profile_detail',
                kwargs={ 'username': request.user.username })
            return HttpResponseRedirect(success_url)
        else:
            return HttpResponseRedirect(reverse('profiles_edit_profile'))
    else:
        return HttpResponseRedirect(reverse('profiles_profile_detail',
                kwargs={ 'username': request.user.username }))

def is_associated(user, provider):
    return bool(UserSocialAuth.objects.filter(user=user, provider=provider))

@login_required
def edit_profile(request, form_class=ProfileForm, success_url=None,
                 template_name='profiles/edit_profile.html',
                 extra_context=None):
    upload_avatar_form = UploadAvatarForm(user=request.user)
    try:
        profile_obj = request.user.get_profile()
    except ObjectDoesNotExist:
        return HttpResponseRedirect(reverse('profiles_create_profile'))

    if success_url is None:
        success_url = reverse('profiles_profile_detail',
                              kwargs={ 'username': request.user.username })

    if request.method == 'POST':
        form = form_class(data=request.POST, files=request.FILES, instance=profile_obj)
        if form.is_valid():
            form.save()
            messages.success(request, 'Your profile has been updated.')
            if request.user.email and not is_subscribed_to_mailchimp(request.user.email, 'User Sign Ups'):
                subscribe_to_mailchimp(request.user, 'User Sign Ups')
            return HttpResponseRedirect(success_url)
    else:
        form = form_class(instance=profile_obj)

    if extra_context is None:
        extra_context = {}
    context = RequestContext(request)
    for key, value in extra_context.items():
        context[key] = callable(value) and value() or value

    data = {
        'form': form,
        'profile': profile_obj,
        'upload_avatar_form': upload_avatar_form,
        }

    data['foursquare_association'] = is_associated(request.user, 'foursquare')

    return render_to_response(template_name, data, context_instance=context)

def incr_count(profile):
    profile.view_count = F('view_count') + 1
    profile.save()
    profile.view_count = Profile.objects.get(pk=profile.pk).view_count


def _get_friends(user):
    return user.get_profile().friends.all().distinct()

def get_friends(request, user):
    all_friends = _get_friends(user)
    paginator = Paginator(all_friends, 9)
    page = request.GET.get('page')

    try:
        page = int(request.GET.get('page', '1'))
    except ValueError:
        page = 1

    # If page request (9999) is out of range, deliver last page of results.
    try:
        friends = paginator.page(page)
    except (EmptyPage, InvalidPage):
        friends = paginator.page(paginator.num_pages)

    return (friends, paginator.num_pages)

def _get_following(user):
    return _get_friends(user)

def get_following(request, user):
    return get_friends(request, user)

def _get_followers(user):
    return user.friends.all().distinct()

def get_followers(request, user):
    all_followers = _get_followers(user)
    paginator = Paginator(all_followers, 9)
    page = request.GET.get('page')

    try:
        page = int(request.GET.get('page', '1'))
    except ValueError:
        page = 1

    # If page request (9999) is out of range, deliver last page of results.
    try:
        followers = paginator.page(page)
    except (EmptyPage, InvalidPage):
        followers = paginator.page(paginator.num_pages)

    return (followers, paginator.num_pages)

def ajax_friends(request, username):
    user = get_object_or_404(User, username=username, is_active=True)
    friends, num_pages = get_friends(request, user)
    return render_to_response('profiles/ajax_friends.html', {
            'friends': friends,
            'num_pages': num_pages,
            }, context_instance=RequestContext(request))

def ajax_following(request, username):
    user = get_object_or_404(User, username=username, is_active=True)
    following, num_pages = get_following(request, user)
    return render_to_response('profiles/ajax_following.html', {
            'following': following,
            'num_pages': num_pages,
            }, context_instance=RequestContext(request))

def ajax_followers(request, username):
    user = get_object_or_404(User, username=username, is_active=True)
    followers, num_pages = get_followers(request, user)
    return render_to_response('profiles/ajax_followers.html', {
            'followers': followers,
            'num_pages': num_pages,
            }, context_instance=RequestContext(request))

def profile_detail(request, username, public_profile_field=None,
                   template_name='profiles/profile_detail.html',
                   extra_context=None):

    user = get_object_or_404(User, username=username, is_active=True)
    sort_key = request.GET.get('order', None)
    order_by = ['-published', 'restaurant__name']
    order = ''

    friends = None
    friends_count = 0
    friends_num_pages = 0

    following = None
    following_count = 0
    following_num_pages = 0

    followers = None
    followers_count = 0
    followers_num_pages = 0

    if sort_key:
        if sort_key == 'score':
            order_by = ['-overall_score', 'restaurant__name']
            order = sort_key
        elif sort_key == 'savant':
            order_by = ['user__first_name', 'restaurant__name']
            order = sort_key
        elif sort_key == 'restaurant':
            order_by = ['restaurant__name']
            order = sort_key
        else:
            order_by = ['-special_sort_key', 'restaurant__name']

    try:
        profile_obj = user.get_profile()
        friends, friends_num_pages = get_friends(request, user)
        friends_count = len(_get_friends(user))
    except ObjectDoesNotExist:
        raise Http404

    try:
        following, following_num_pages = get_following(request, user)
        following_count = len(_get_following(user))
    except ObjectDoesNotExist:
        raise Http404

    try:
        followers, followers_num_pages = get_followers(request, user)
        followers_count = len(_get_followers(user))
    except ObjectDoesNotExist:
        raise Http404

    if public_profile_field is not None and \
       not getattr(profile_obj, public_profile_field):
        profile_obj = None

    if extra_context is None:
        extra_context = {}
    context = RequestContext(request)
    for key, value in extra_context.items():
        context[key] = callable(value) and value() or value

    # check if user should see edit/delete fields
    if user == request.user:
        is_user = True
    else:
        incr_count(profile_obj)
        is_user = False

    # Paginate this, see if it speeds things up
    reviews = Review.objects.filter(
        user=user,
        restaurant__active=True,
        active=True
    ).with_special_sort_key(
    ).order_by(*order_by)
    paginator = Paginator(reviews, 10, request=request)
    page = request.GET.get('page')
    try:
        page = int(request.GET.get('page', '1'))
    except ValueError:
        page = 1

    try:
        reviews = paginator.page(page)
    except (EmptyPage, InvalidPage):
        reviews = paginator.page(paginator.num_pages)

    # Generate order query strings
    order_by_score = request.GET.copy()
    order_by_score['order'] = 'score'
    order_by_score = order_by_score.urlencode()
    order_by_restaurant = request.GET.copy()
    order_by_restaurant['order'] = 'restaurant'
    order_by_restaurant = order_by_restaurant.urlencode()
    order_by_date = request.GET.copy()
    order_by_date['order'] = 'date'
    order_by_date = order_by_date.urlencode()

    blackbooks = user.collection_set.order_by('pk')[:4]

    return render_to_response(template_name, {
            'blackbooks': blackbooks,
            'order': order,
            'compose_form': ComposeForm,
            'profile': profile_obj,
            'is_user': is_user,
            'friends': friends,
            'friends_count': friends_count,
            'friends_num_pages': friends_num_pages,
            'following': following,
            'following_count': following_count,
            'following_num_pages': following_num_pages,
            'followers': followers,
            'followers_count': followers_count,
            'followers_num_pages': followers_num_pages,
            'paginator': paginator,
            'page': reviews,
            'url': request.path,
            'order_by_score': order_by_score,
            'order_by_restaurant': order_by_restaurant,
            'order_by_date': order_by_date,
        }, context_instance=context)

def follow(request, username, success_url=None):
    user = get_object_or_404(User, username=username)
    try:
        profile = request.user.get_profile()
    except ObjectDoesNotExist:
        raise Http404
    profile.add_friend(user)

    if request.is_ajax():
        # We don't want to send a redirect to an Ajax call, because that could
        # obscure the success or failure of this action by encountering an error
        # on the subsequent page. We want to just send a 204, to say "Yes, I did
        # this." and no more.
        return HttpResponse(status=204)

    if success_url is None:
        success_url = reverse('profiles_profile_detail',
                              kwargs={'username': username})

    return HttpResponseRedirect(success_url)

def unfollow(request, username, success_url=None):
    user = get_object_or_404(User, username=username)
    try:
        profile = request.user.get_profile()
    except ObjectDoesNotExist:
        raise Http404
    profile.remove_friend(user)

    if request.is_ajax():
        # We don't want to send a redirect to an Ajax call, because that could
        # obscure the success or failure of this action by encountering an error
        # on the subsequent page. We want to just send a 204, to say "Yes, I did
        # this." and no more.
        return HttpResponse(status=204)

    if success_url is None:
        success_url = reverse('profiles_profile_detail',
                              kwargs={'username': username})

    return HttpResponseRedirect(success_url)

def profile_list(request, public_profile_field=None,
                 template_name='profiles/profile_list.html', **kwargs):
    profile_model = utils.get_profile_model()
    queryset = profile_model._default_manager.all()
    if public_profile_field is not None:
        queryset = queryset.filter(**{ public_profile_field: True })
    kwargs['queryset'] = queryset
    return object_list(request, template_name=template_name, **kwargs)

@login_required
def follower_suggestions(request):
    user = request.user
    # We use a list of tuples here so that we can control the order in which these
    # categories display. If we had py2.7 on the server, we could use an OrderedDict!
    suggestions_dict = []
    suggestions_dict.append(('Friends of Friends', suggest_friends_of_friends(user)))
    suggestions_dict.append(('People Following You', suggest_reciprocal_friends(user)))
    suggestions_dict.append(('Most Active Users', suggest_most_active_users(user)))
    suggestions_dict.append(('Bloggers', suggest_bloggers(user)))
    data = {
        'suggestions_dict': suggestions_dict,
        'friends': user.get_profile().friends.all(),
    }
    return render_to_response('profiles/suggestions.html', data, context_instance=RequestContext(request))

def profile_detail_followers(request, username):
    user = get_object_or_404(User, username=username)
    data = {
        'profile': user.get_profile(),
        'friends': User.objects.filter(profile__friends=user)
    }
    return render_to_response('profiles/followers-full-page.html', data,
        context_instance=RequestContext(request))

def profile_detail_following(request, username):
    user = get_object_or_404(User, username=username)
    data = {
        'profile': user.get_profile(),
        'friends': user.get_profile().friends.all(),
    }
    return render_to_response('profiles/following-full-page.html', data,
        context_instance=RequestContext(request))

def delete_account(request):
    if request.user.is_authenticated():
        data = {
            'confirm': True
        }
        if request.method == 'POST':
            user = request.user
            logout(request)
            if is_subscribed_to_mailchimp(user, 'User Sign Ups'):
                unsubscribe_from_mailchimp(user, 'User Sign Ups')
            user.is_active = False
            user.save()
            for review in Review.objects.filter(user=user):
                review.active = False
                review.save()
            data['confirm'] = False
        return render_to_response('profiles/delete.html', data, context_instance=RequestContext(request))
    else:
        raise Http404

@login_required
def link_accounts(request):
    has_facebook = is_associated(request.user, 'facebook')
    has_twitter = is_associated(request.user, 'twitter')
    data = {
        'social_auth_list': UserSocialAuth.objects.filter(user=request.user),
        'has_facebook': has_facebook,
        'has_twitter': has_twitter,
    }
    return render_to_response('profiles/link.html', data,
        context_instance=RequestContext(request))
