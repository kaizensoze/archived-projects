from django.http import Http404
from django.conf import settings
from django.contrib import messages
from django.contrib.sites.models import Site
from django.db import transaction
from django.db.models import F, Q, Avg
from django.shortcuts import render_to_response
from django.template import RequestContext

from taste.apps.newsfeed.models import Activity
from taste.apps.restaurants.models import Restaurant
from taste.apps.reviews.forms import WriteReviewForm
from taste.apps.reviews.models import Review, ReviewDish, Dish, Score
from taste.apps.search.forms import ExtendedSearchForm
from taste.apps.singleplatform.models import Menu

from django_messages.forms import ComposeForm
from datetime import datetime
from social_auth.models import UserSocialAuth
import re
from urllib import urlencode


# @todo: Explanatory comment to explain what this does? --kit
# @note: Perhaps move this to a utils.py? --kit
def round_score(score):
    score = round(score)
    if score >= 0 and score <= 4:
        return 'ditch'
    if score >= 5 and score <= 7:
        return 'walk'
    if score >= 8 and score <= 10:
        return 'run'


def get_friends(user):
    return user.get_profile().friends.all()


def get_savant_overall(restaurant):
    return Score.objects.filter(
        review__restaurant=restaurant,
        review__active=True,
        review__user__isnull=False).aggregate(
        overall=Avg('value'))['overall']


def get_friends_overall(restaurant, user):
    friends = get_friends(user)

    if friends:
        return Score.objects.filter(
            review__restaurant=restaurant,
            review__active=True,
            review__user__in=friends).aggregate(
            overall=Avg('value'))['overall']
    else:
        return False


def get_scores(restaurant, user):
    review = Review.objects.filter(
        restaurant=restaurant,
        active=True)

    scores = review.aggregate(
        ambience=Avg('ambience_score'),
        food=Avg('food_score'),
        service=Avg('service_score'))

    savant_overall = get_savant_overall(restaurant)

    if scores['ambience']:
        scores['ambience'] = int(scores['ambience'])
    else:
        scores.pop('ambience')
    if scores['food']:
        scores['food'] = int(scores['food'])
    else:
        scores.pop('food')
    if scores['service']:
        scores['service'] = int(scores['service'])
    else:
        scores.pop('service')

    if savant_overall:
        scores['savants'] = round_score(savant_overall)
        scores['savants_score'] = savant_overall

    if user.is_authenticated():
        friends_overall = get_friends_overall(restaurant, user)
        if friends_overall:
            scores['friends'] = 'images/large-{score}.png'.format(
                score=round_score(friends_overall)
            )
            scores['friends_score'] = friends_overall

    return scores


def process_dishes(review, recommended, dishes_to_save, existing_dishes):
    dishes_to_save = [
        dish_name.lower().strip()
        for dish_name in re.split(',|;|\n', dishes_to_save)
        if len(dish_name.strip()) > 0
    ]
    existing_dishes = [
        dish.name for dish in existing_dishes if len(dish.name.strip()) > 0
    ]

    if dishes_to_save:
        for dish in dishes_to_save:
            if dish not in existing_dishes:
                try:
                    obj, created = Dish.objects.get_or_create(name=dish)
                except Dish.MultipleObjectsReturned:
                    # In case there are still duplicates in the database, we
                    # handle that eventuality. We should clean out the
                    # database so this route never happens, but handling it
                    # gracefully is better than handling it with a server
                    # error.
                    obj = Dish.objects.filter(name=dish)[0]
                ReviewDish.objects.create(dish=obj, review=review,
                                          recommended=recommended)

    if existing_dishes:
        for dish in existing_dishes:
            if dish not in dishes_to_save:
                ReviewDish.objects.filter(
                    dish__name=dish,
                    review=review,
                    recommended=recommended
                ).delete()


@transaction.commit_on_success
def create_edit_review(request, restaurant, data):
    template = "restaurants/detail-create.html"
    if request.user.is_authenticated():
        if request.method == 'POST':
            form = WriteReviewForm(request.POST)
            if form.is_valid():
                score = Score.objects.get(
                    value=form.cleaned_data['overall_score'])

                try:
                    review = Review.objects.filter(
                        restaurant=restaurant,
                        user=request.user,
                        active=True).with_special_sort_key(
                        ).order_by('-special_sort_key')[0]
                except:
                    review = Review.objects.create(
                        active=True,
                        restaurant=restaurant,
                        user=request.user,
                        published=datetime.today(),
                        overall_score=form.cleaned_data['overall_score'],
                        ambience_score=form.cleaned_data['ambience_score'],
                        service_score=form.cleaned_data['service_score'],
                        food_score=form.cleaned_data['food_score'],
                        body=form.cleaned_data['review'],
                        summary=form.cleaned_data['review'],
                        score=score
                    )

                review.active = True
                review.restaurant = restaurant
                review.user = request.user
                review.published = datetime.today()
                review.overall_score = form.cleaned_data['overall_score']
                review.ambience_score = form.cleaned_data['ambience_score']
                review.service_score = form.cleaned_data['service_score']
                review.food_score = form.cleaned_data['food_score']
                review.body = form.cleaned_data['review']
                review.summary = form.cleaned_data['review']
                review.score = score

                process_dishes(
                    review,
                    True,
                    form.cleaned_data['good_dishes'],
                    list(review.good_dishes)
                )
                process_dishes(
                    review,
                    False,
                    form.cleaned_data['bad_dishes'],
                    list(review.bad_dishes)
                )

                review.more_tips = form.cleaned_data['more_tips']
                review.save()

                # Update the template variables, which are inexplicably set in
                # an outer function call before this one, so they're set
                # before the review is saved.
                savant_score = get_savant_overall(restaurant)
                data['savants_score'] = savant_score
                data['savants'] = round_score(savant_score)

                # This used to go through the messages system, but that was
                # insufficiently visible. So it shows up in two places now.
                data['success_message'] = (
                    "Thanks, your review is currently "
                    "pending staff approval and will be "
                    "posted momentarily."
                )
                messages.success(
                    request,
                    "Thanks, your review is currently "
                    "pending staff approval and will be "
                    "posted momentarily."
                )
        else:
            initial = {}
            try:
                review = Review.objects.filter(
                    restaurant=restaurant,
                    user=request.user,
                    active=True).with_special_sort_key(
                    ).order_by('-special_sort_key')[0]

                initial = {
                    'overall_score': review.overall_score,
                    'food_score': review.food_score,
                    'ambience_score': review.ambience_score,
                    'service_score': review.service_score,
                    'review': review.summary,
                    'good_dishes': ",".join([
                        good_dish.name
                        for good_dish in list(review.good_dishes)
                    ]),
                    'bad_dishes': ",".join([
                        bad_dish.name for bad_dish in list(review.bad_dishes)
                    ]),
                    'more_tips': [
                        tip.id for tip in list(review.more_tips.all())
                    ],
                }
            except:
                pass

            form = WriteReviewForm(initial=initial)

        site = u'http://' + Site.objects.get_current().domain
        restaurant_name = data['restaurant'].name
        if len(restaurant_name) > 55:
            restaurant_name = restaurant_name[:54] + "\xE2\x80\xA6"  # ellipsis

        data['FACEBOOK_APP_ID'] = settings.FACEBOOK_APP_ID
        data['tweet_text'] = urlencode({
            'status': u"I reviewed {name} on @TasteSavant and scored it javascript-score. Check it out at {url}".format(
                name=restaurant_name,
                url=(site + data['restaurant'].get_absolute_url() + u'review/savants/')
            ).encode('utf-8')
        })
        data['facebook_text'] = urlencode({
            'app_id': settings.FACEBOOK_APP_ID,
            'link': (site + data['restaurant'].get_absolute_url() + u'review/savants/'),
            'picture': 'http://tastesavant.com/media/images/logo-main.png',
            'name': u'Review of {name} on Taste Savant'.format(
                name=data['restaurant'].name
            ).encode('utf-8'),
            'caption': u'Check out my review of {name} on Taste Savant! I gave it a {score}.'.format(
                name=data['restaurant'].name,
                score='javascript-score'
            ).encode('utf-8'),
            'description': 'javascript-description',
            'redirect_uri': site + '/social/complete/facebook/',
        })
        data['write_review_form'] = form
        scores = get_scores(restaurant, request.user)
        data.update(**scores)

    return render_to_response(template, data,
                              context_instance=RequestContext(request))


def friends_activity(friends, restaurant):
    return Activity.objects.filter(restaurant=restaurant,
                                   user__in=friends).order_by('-occurred')[:6]


def friends(request, restaurant, data):
    template = 'restaurants/detail-friends.html'
    if request.user.is_authenticated():
        order = ''
        order_by = '-special_sort_key'
        url_query = request.GET.copy()
        sort_key = request.GET.get('order', None)

        if sort_key:
            if sort_key == 'score':
                order_by = '-overall_score'
                order = sort_key
            elif sort_key == 'savant':
                order_by = 'user__first_name'
                order = sort_key
            elif sort_key == 'agree':
                order_by = '-special_sort_key'
                order = sort_key
            else:
                order_by = '-special_sort_key'
                del url_query['order']

        url = request.path_info + '?'
        friends = request.user.get_profile().friends.all()
        data['FACEBOOK_APP_ID'] = settings.FACEBOOK_APP_ID
        data['url'] = url
        data['compose_form'] = ComposeForm
        data['order'] = order
        data['activity'] = friends_activity(friends, restaurant)
        data['reviews'] = Review.objects.filter(
            user__in=friends,
            restaurant=restaurant
        ).with_special_sort_key(
        ).order_by(order_by)
        scores = get_scores(restaurant, request.user)
        data.update(**scores)

    return render_to_response(template, data,
                              context_instance=RequestContext(request))


def savants(request, restaurant, data):
    order = ''
    order_by = '-special_sort_key'
    url_query = request.GET.copy()
    sort_key = request.GET.get('order', None)

    if sort_key:
        if sort_key == 'score':
            order_by = '-overall_score'
            order = sort_key
        elif sort_key == 'savant':
            order_by = 'user__first_name'
            order = sort_key
        elif sort_key == 'agree':
            order_by = '-special_sort_key'
            order = sort_key
        else:
            order_by = '-special_sort_key'
            del url_query['order']

    url = request.path_info + '?'

    template = 'restaurants/detail-savants.html'
    data['FACEBOOK_APP_ID'] = settings.FACEBOOK_APP_ID
    data['url'] = url
    data['order'] = order
    data['user_reviews'] = Review.objects.filter(
        restaurant=restaurant,
        user__isnull=False
    ).with_special_sort_key(
    ).order_by(order_by)
    scores = get_scores(restaurant, request.user)
    data.update(**scores)

    return render_to_response(template, data,
                              context_instance=RequestContext(request))


# @note: Perhaps move this to a utils.py? --kit
def incr_count(restaurant):
    restaurant.hits = F('hits') + 1
    restaurant.save()
    restaurant.hits = Restaurant.objects.get(pk=restaurant.pk).hits


def menu(request, restaurant):
    restaurant = Restaurant.objects.get(slug=restaurant)
    menus = Menu.objects.filter(restaurant=restaurant)
    if not menus.count():
        raise Http404
    return render_to_response(
        'singleplatform/menus.html',
        {
            'menus': menus,
            'restaurant': restaurant,
            'host': request.get_host(),
            'extended_search_form': ExtendedSearchForm()
        },
        context_instance=RequestContext(request))


def restaurant(request, restaurant, review=None, review_id=None):
    restaurant = Restaurant.objects.get(slug=restaurant)

    # @todo: remove after TEMP TESTING
    if restaurant.opentable:
        restaurant.opentable_widget_link = restaurant.opentable.replace(
            'single',
            'frontdoor/default'
        )

    if not restaurant.active:
        raise Http404

    incr_count(restaurant)

    extended_search_form = ExtendedSearchForm(request.GET)
    template = 'restaurants/detail.html'

    data = {
        'FACEBOOK_APP_ID': settings.FACEBOOK_APP_ID,
        'restaurant': restaurant,
        'host': request.get_host(),
        'extended_search_form': extended_search_form,
    }
    if request.user.is_authenticated():
        data.update({
            'has_twitter': bool(UserSocialAuth.objects.filter(
                provider='twitter',
                user=request.user).count()
            ),
            'has_facebook': bool(UserSocialAuth.objects.filter(
                provider='facebook',
                user=request.user).count()
            ),
        })
    else:
        data.update({
            'has_twitter': False,
            'has_facebook': False,
        })

    data['reviews'] = Review.objects.filter(
        restaurant__slug=restaurant.slug,
        user=None
    ).with_special_sort_key().order_by('-special_sort_key', 'id')

    current_site = Site.objects.get_current()
    data['display_occasions'] = restaurant.occasion.filter(site=current_site, active=True)
    data['restaurant_api_uri'] = '/api/1/restaurants/{}/'.format(
        restaurant.slug
    )

    if review:
        if review == 'create_edit':
            return create_edit_review(request, restaurant, data)
        if review == 'savants':
            return savants(request, restaurant, data)
        if review == 'friends':
            return friends(request, restaurant, data)
        else:
            return render_to_response(template, data,
                                      context_instance=RequestContext(request))
    else:
        scores = get_scores(restaurant, request.user)
        data.update(**scores)
        return render_to_response(template, data,
                                  context_instance=RequestContext(request))
