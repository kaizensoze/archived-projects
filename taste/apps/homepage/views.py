from random import randint
from datetime import datetime, timedelta

from django.conf import settings
from django.contrib import messages
from django.contrib.auth.models import User
from django.contrib.sites.models import Site
from django.core.paginator import Paginator, InvalidPage, EmptyPage
from django.db.models import Q, Count
from django.http import HttpResponseRedirect
from django.template.defaultfilters import slugify
from django.template.response import TemplateResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.views.decorators.cache import never_cache

from taste.apps.comingsoon.models import EmailForm
from taste.apps.newsfeed.models import Activity, Action
from taste.apps.homepage.utils import OrderedSet
from taste.apps.restaurants.models import Restaurant
from taste.apps.reviews.models import Review
from taste.apps.toplist.models import TopList
from taste.apps.search.forms import ExtendedSearchForm
from taste.apps.profiles.utils import (suggest_bloggers,
    suggest_most_active_users, suggest_friends_of_friends,
    suggest_reciprocal_friends, subscribe_to_mailchimp)

def get_friends(user):
    return user.get_profile().friends.all()

def get_friends_activity(request):
    friends = get_friends(request.user)
    reviewed = Action.objects.get(action_name='reviewed')

    activity_feed = Activity.objects.filter(
        Q(user__in=friends)|Q(user=request.user),
        Q(action=reviewed,
            restaurant__active=True)|~Q(action=reviewed)
        ).order_by('-occurred')

    fillers = range(5-activity_feed.count())

    paginator = Paginator(activity_feed, 5)

    page = request.GET.get('page')

    try:
        page = int(request.GET.get('page', '1'))
    except ValueError:
        page = 1

    # If page request (9999) is out of range, deliver last page of results.
    try:
        activity = paginator.page(page)
    except (EmptyPage, InvalidPage):
        activity = paginator.page(paginator.num_pages)
    if paginator.count == 0:
        activity = None
    return (activity, paginator.num_pages, fillers)

@never_cache
def ajax_activity_feed(request):
    activity, num_pages, fillers = get_friends_activity(request)
    return render_to_response('homepage/ajax_activity.html',
        {'friends':activity, 'fillers':fillers},
        context_instance=RequestContext(request))

def get_new_critic_reviews(limit):
    current_site = Site.objects.get_current()
    return Review.objects.filter(
        Q(user=None),
        restaurant__active=True,
        restaurant__site=current_site
    ).with_special_sort_key(
    ).order_by('-special_sort_key')[0:limit]

def get_new_user_reviews(limit):
    current_site = Site.objects.get_current()
    return Review.objects.filter(
        active=True,
        restaurant__active=True,
        restaurant__site=current_site
    ).exclude(
        user=None
    ).with_special_sort_key(
    ).order_by('-special_sort_key')[0:limit]

def get_new_on_the_scene(limit):
    return Restaurant.on_site.filter(
        active=True,
        occasion__name = 'NEW On The Scene').order_by('?')[0:limit]

def get_prompt(request):
    if request.method == 'GET':
        prompt = request.GET.get('p', None)
        if prompt and prompt == 'login':
            return 'login'

def hottest_reviewers(limit=None):
    return User.objects.filter(
        profile__type_expert__isnull=False,
        profile__type_reviewer__isnull=False
    ).annotate(count=Count('review'))\
    .filter(count__gte=4).order_by('?')[0:limit]

def toplist():
    try:
        toplists = TopList.on_site.filter(active=True)
        random_idx = randint(0, len(toplists)-1)
        toplist = toplists[random_idx]
    except:
        toplist = None
    return toplist


def homepage(request):
    if request.method == 'POST':
        form = EmailForm(request.POST)
        if form.is_valid():
            email_address = form.save()
            email_address = str(email_address)
            subscribe_to_mailchimp(email_address, 'Newsletter Sign Ups')
            messages.success(request,
                "Thanks for signing up! "
                "We'll keep you posted on any new and exciting updates.")
            referer = request.META.get('HTTP_REFERER', '/')
            return HttpResponseRedirect(referer)

    extended_search_form = ExtendedSearchForm()

    follow_suggestions = ()
    if request.user.is_authenticated():
        follow_suggestions = (
            suggest_friends_of_friends(request.user),
            suggest_reciprocal_friends(request.user),
            suggest_most_active_users(request.user),
            suggest_bloggers(request.user),
        )

    follow_suggestions_set = OrderedSet()
    for group in follow_suggestions:
        for elem in group:
            follow_suggestions_set.add(elem)

    data = {
        'extended_search_form': extended_search_form,
        'toplist': toplist(),
        'follow_suggestions': follow_suggestions_set,
        'follow_suggestions_width': len(follow_suggestions_set) * 140,
        }

    if request.user.is_authenticated():
        activity, num_pages, fillers = get_friends_activity(request)
        if activity:
            data['friends'] = activity
            data['num_pages'] = num_pages
            data['fillers'] = fillers
        else:
            data['hottest'] = hottest_reviewers(5)
        data['new_critic_reviews'] = get_new_critic_reviews(4)
        data['new_user_reviews'] = get_new_user_reviews(3)
        if activity:
            data['restaurants'] = get_new_on_the_scene(7)
        else:
            data['restaurants'] = get_new_on_the_scene(8)
    else:
        data['prompt'] = get_prompt(request)
        data['new_critic_reviews'] = get_new_critic_reviews(4)
        data['new_user_reviews'] = get_new_user_reviews(3)
        data['restaurants'] = get_new_on_the_scene(4)
        data['hottest'] = hottest_reviewers(4)

    response = TemplateResponse(request, 'homepage/default.html', data)

    # If the user has never visited before (as indicated by a lack of a
    # "visited" cookie from us), then show them a splash page and set a
    # "visited" cookie.
    if 'visited' not in request.COOKIES:
        data['show_splash'] = True
        current_site = Site.objects.get_current()
        if current_site.name == 'Chicago':
            interpolate = slugify(current_site.name)
        else:
            interpolate = 'new-york'
        data['splash_for_city'] = 'splash/splash-%s.png' % interpolate
    far_in_the_future = datetime.now() + timedelta(days=365 * 5)
    response.set_cookie(
        'visited',
        'True',
        expires=far_in_the_future,
        domain=settings.SESSION_COOKIE_DOMAIN
    )

    return response


def get_the_app(request):
    context = {
        'next': request.GET.get('next', '/'),
        'app_store_link': 'https://itunes.apple.com/us/app/taste-savant/id828925581?mt=8',
    }
    response = render_to_response('mobile_splash.html', context)
    far_in_the_future = datetime.now() + timedelta(days=365 * 5)
    response.set_cookie(
        'mobile_splashed',
        'True',
        expires=far_in_the_future,
        domain=settings.SESSION_COOKIE_DOMAIN
    )
    return response
