from django.conf import settings
from django.contrib.sites.models import Site
from django.db.models import Avg, Sum, Q
from django.utils.html import escape
from taste.apps.restaurants.models import Restaurant, Location
from taste.apps.reviews.models import Score
from pure_pagination import Paginator, PageNotAnInteger
from django.views.decorators.csrf import csrf_exempt

from django.contrib.auth.models import User
from django.shortcuts import render_to_response, HttpResponse
from django.template import RequestContext
from haystack.forms import SearchForm
from haystack.query import EmptySearchQuerySet
from haystack.query import SearchQuerySet
from taste.apps.search.forms import ExtendedSearchForm
from django.utils import simplejson

from profiles.utils import FOLLOW_SUGGESTION_STOPLIST

from restaurants.views import get_friends_overall

htmlCodes = (
    ('&', '&amp;'),
    ('"', '&quot;'),
    ("'", '&#39;'),
)

def apply_sorting(results, request, search_type='widget'):
    if 'sort' in request.GET:
        order_by = request.GET['sort']
        if order_by == 'restaurant':
            if search_type == 'widget':
                return results.order_by('name')
            if search_type == 'solr':
                return sorted(results, key=lambda r: r.name)
        if order_by == 'savant':
            if search_type == 'widget':
                return results.order_by('-savants_say')
            if search_type == 'solr':
                return sorted(results, key=lambda r: r.savants_say, reverse=True)
        if order_by == 'friends':
            return sorted(results, key=lambda r: r.friends_score, reverse=True)
        if order_by == 'critic':
            if search_type == 'widget':
                return results.order_by('-critics_say')
            if search_type == 'solr':
                return sorted(results, key=lambda r: r.critics_say, reverse=True)
        if order_by == 'price-asc':
            if search_type == 'widget':
                return results.order_by('price__name')
            elif search_type == 'solr':
                return sorted(results, key=lambda r: r.object.price.name, reverse=False)
        if order_by == 'price-desc':
            if search_type == 'widget':
                return results.order_by('-price__name')
            elif search_type == 'solr':
                return sorted(results, key=lambda r: r.object.price.name, reverse=True)
        else:
            return results
    elif 'q' not in request.GET:
        # if no query is defined, sort by critic by default.
        if search_type == 'widget':
            return results.order_by('-critics_say')
        if search_type == 'solr':
            return sorted(results, key=lambda r: r.critics_say, reverse=True)
    else:
        return results


@csrf_exempt
def auto_complete_user_search(request):
    if request.method == 'POST':
        query = request.POST.get('q', '')
        data = User.objects.filter(
            Q(username__icontains=query)
            | Q(first_name__icontains=query)
            | Q(last_name__icontains=query)
            | Q(profile__first_name__icontains=query)
            | Q(profile__last_name__icontains=query)
            | Q(email__icontains=query)
        ).filter(
            is_superuser=False
        ).filter(
            is_staff=False
        ).exclude(username__in=FOLLOW_SUGGESTION_STOPLIST)

        order_fields = []
        if request.user.is_authenticated():
            # EXTREME WARNING
            # A) We're using .extra here, that's bad.
            # B) We're ignoring warnings here. That's also bad.
            # MySQL complains, incoherently, that it's truncating data on this
            # select. So we're just gonna tell it to shut up.
            import warnings
            warnings.simplefilter('ignore')
            # The above shouldn't last past the one request.
            # Let's set FOAF values, so we can show them first.
            data = data.extra(
                select={
                    'foaf': ('`auth_user`.`id` IN'
                             ' (SELECT `profiles_friendship`.`user_id`'
                             ' FROM `profiles_friendship`'
                             ' WHERE `profiles_friendship`.`profile_id`'
                             ' IN (%s))')
                },
                select_params=[
                    ', '.join(
                        str(obj.pk)
                        for obj in request.user.get_profile().friends.all()
                    )
                ]
            )
            order_fields.append('-foaf')

        order_fields.append('-review_count')
        data = data\
            .annotate(review_count=Sum('review__active'))\
            .order_by(*order_fields)[:10]
            # Limit to ten, to keep Mootools autocomplete from panicking.
    else:
        data = []
    return render_to_response(
        'search/ajax_user_lookup.html',
        {'results': data},
        context_instance=RequestContext(request)
    )

@csrf_exempt
def auto_complete_search(request):
    if request.method == 'POST':
        query = request.POST.get('q', '')
        sqs = Restaurant.on_site.filter(name__icontains=query, active=True)
        data = [x.name for x in sqs]
    else:
        data = []
    return HttpResponse(simplejson.dumps(data), mimetype='application/json')


def ajax_search(request):
    template = 'search/haystack-results.html'
    load_all = True
    form_class = SearchForm
    searchqueryset = SearchQuerySet().models(Restaurant)
    context_class = RequestContext
    extra_context = None
    results_per_page = 10
    displayAll = False

    query = ''
    results = EmptySearchQuerySet()

    if 'sort' in request.GET:
        sort_by = request.GET['sort']
    else:
        sort_by = 'critic'

    if request.GET.get('q'):
        get_values = request.GET.copy()
        get_values['q'] = escape(request.GET.get('q'))

        form = form_class(get_values,
            searchqueryset=searchqueryset, load_all=load_all)

        current_site = Site.objects.get_current()
        if form.is_valid():
            query = form.cleaned_data['q']
            # Shenanigans to get around a bug in SearchForm under py2.6.
            # Basically, if any result in form.search() doesn't match a model
            # in the current DB, it returns the last item returned, again, in
            # a new SearchResult object. Or something like that. In any case,
            # we have to manually ensure uniqueness here, by model and not by
            # SearchResult.
            res = {}
            for r in form.search():
                if (r is not None
                    and r.content_type() == 'restaurants.restaurant'
                    and r.object.site == current_site):
                    res[r.object] = r
            results = res.values()
            if request.user.is_authenticated():
                for result in results:
                    result.friends_score = restaurant_friends_score(result.object, request.user)
            results = apply_sorting(results, request, search_type='solr')
    else:
        form = form_class(searchqueryset=searchqueryset, load_all=load_all)

    try:
        page = request.GET.get('page', 1)
    except PageNotAnInteger:
        page = 1

    #Checks if request data contains a `display` parameter, and
    #ensures that the queryset contains less than 100 results.
    if 'display' in request.GET and request.GET['display'] == 'all':
        displayAll = True
        if len(results) <= 100:
            paginator = Paginator(results, 100, request=request)
            page = 1
        else:
            paginator = Paginator(results, results_per_page, request=request)
    else:
        paginator = Paginator(results, results_per_page, request=request)
        if paginator.num_pages <= 1:
            displayAll = True


    #BUG/WORKAROUND: for some reason search fails when it contains
    #special characters. Oddly this fixes it, I just don't know why.
    try:
        page = paginator.page(page)
    except:
        page = paginator

    # Append request-contextual data to the entries *in this page*, like
    # friends-overall-score.
    if request.user.is_authenticated():
        for r in page.object_list:
            r.object.friends_score = get_friends_overall(r.object, request.user) or None
    context = {
        'sort_by': sort_by,
        'form': form,
        'displayAll': displayAll,
        'page': page,
        'paginator': paginator,
        'query': query,
        'suggestion': form.get_suggestion(),
        'extended_search_form': ExtendedSearchForm(),
        'site_id': settings.SITE_ID
    }

    if getattr(settings, 'HAYSTACK_INCLUDE_SPELLING', False):
        context['suggestion'] = form.get_suggestion()

    if extra_context:
        context.update(extra_context)

    return render_to_response(template, context,
        context_instance=context_class(request))


def basic_search(request, template='search/search.html', load_all=True,
    context_class=RequestContext, extra_context=None, results_per_page=10,
    displayAll=None):
    form_class = SearchForm
    searchqueryset = SearchQuerySet().models(Restaurant)

    if request.GET.get('q'):
        get_values = request.GET.copy()
        get_values['q'] = escape(request.GET.get('q'))

        form = form_class(get_values,
            searchqueryset=searchqueryset, load_all=load_all)

        if form.is_valid():
            # We actually do stuff in the ajax call.
            pass

    else:
        form = form_class(searchqueryset=searchqueryset, load_all=load_all)

    if 'sort' in request.GET:
        sort_by = request.GET['sort']
    else:
        sort_by = 'critic'

    full_path = request.get_full_path()
    if 'sort' in request.GET:
        full_path = full_path.replace('sort=%s' % sort_by, '')
        full_path = full_path.replace('&&', '&')
        full_path = full_path.replace('?&', '?')
        if full_path[-1] == "&":
            full_path = full_path[:-1]

    context = {
        'sort_by': sort_by,
        'advanced_ajax_search': False,
        'suggestion': form.get_suggestion(),
        'extended_search_form': ExtendedSearchForm(),
        'query_string': request.GET.urlencode(),
        'url': full_path,
        'site_id': settings.SITE_ID
    }

    if getattr(settings, 'HAYSTACK_INCLUDE_SPELLING', False):
        context['suggestion'] = form.get_suggestion()

    if extra_context:
        context.update(extra_context)

    return render_to_response(template, context,
        context_instance=context_class(request))


def advanced_ajax_search(request, template='search/haystack-results.html',
    results_per_page=10, context_class=RequestContext):
    extended_search_form = ExtendedSearchForm(request.GET)

    if extended_search_form.is_valid():
        if 'sort' in request.GET:
            sort_by = request.GET['sort']
        else:
            sort_by = 'critic'

        full_path = request.get_full_path()
        if 'sort' in request.GET:
            full_path = full_path.replace('sort=%s' % sort_by, '')
            full_path = full_path.replace('&&', '&')
            full_path = full_path.replace('?&', '?')
            if full_path[-1] == "&":
                full_path = full_path[:-1]

        prices = extended_search_form.cleaned_data['price']
        cuisines = extended_search_form.cleaned_data['cuisine']
        neighborhoods = extended_search_form.cleaned_data['neighborhood']
        occasions = extended_search_form.cleaned_data['occasion']
        restaurants = Restaurant.on_site.filter(active=1).all()

        if prices:
            restaurants = restaurants.filter(price__in=prices)

        if cuisines:
            restaurants = restaurants.filter(cuisine__in=cuisines).distinct()

        locations = None
        if neighborhoods:
            excludes = []

            for n in neighborhoods:
                if n.get_descendant_count() > 0:
                    excludes.append(n.id)

            neighborhoods = neighborhoods.exclude(id__in=excludes)
            locations = Location.objects.filter(neighborhood__in=neighborhoods)
            restaurants = restaurants.filter(location__in=locations).distinct()

        if occasions:
            for occasion in occasions:
                restaurants = restaurants.filter(occasion__in=[occasion]).distinct()

        defaulted_to_backup_search = False
        if locations and not restaurants:
            restaurants = backup_search(locations)
            defaulted_to_backup_search = True

        # If user is logged in, set friends_score for each restaurant.
        sort_by_friends_score = request.GET.get('sort', '') == 'friends'
        if sort_by_friends_score and request.user.is_authenticated():
            for restaurant in restaurants:
                restaurant.friends_score = restaurant_friends_score(
                    restaurant,
                    request.user
                )

        results = apply_sorting(restaurants, request)

        try:
            page = request.GET.get('page', 1)
        except PageNotAnInteger:
            page = 1

        if 'display' in request.GET and request.GET['display'] == 'all':
            if len(results) <= 100:
                paginator = Paginator(results, 100, request=request)
                page = 1
            else:
                paginator = Paginator(results, results_per_page, request=request)
        else:
            paginator = Paginator(results, results_per_page, request=request)

        page = paginator.page(page)
        if not sort_by_friends_score and request.user.is_authenticated():
            for result in page.object_list:
                result.friends_score = restaurant_friends_score(
                    result,
                    request.user
                )

        # @note: What the devil is this? It's deleting things from a dict that
        # doesn't seem to get subsequently used. All-around weird. -Kit 6/22/12
        url_query = request.GET.copy()
        if 'sort' in url_query:
            del url_query['sort']
        if 'page' in url_query:
            del url_query['page']

        context = {
            'sort_by': sort_by,
            'form': None,
            'page': page,
            'advanced': url_query.urlencode(),
            'paginator': paginator,
            'query': None,
            'suggestion': None,
            'extended_search_form': extended_search_form,
            'defaulted_to_backup_search': defaulted_to_backup_search,
            'url': full_path,
            'site_id': settings.SITE_ID
        }

        return render_to_response(template, context,
            context_instance=context_class(request))
    return HttpResponse('<h2>There was an error with the form.</h2>')


def advanced(request, template='search/search.html', results_per_page=10,
    context_class=RequestContext):
    extended_search_form = ExtendedSearchForm(request.GET)

    if 'sort' in request.GET:
        sort_by = request.GET['sort']
    else:
        sort_by = 'critic'

    full_path = request.get_full_path()
    if 'sort' in request.GET:
        full_path = full_path.replace('sort=%s' % sort_by, '')
        full_path = full_path.replace('&&', '&')
        full_path = full_path.replace('?&', '?')
        if full_path[-1] == "&":
            full_path = full_path[:-1]

    context = {
        'url': full_path,
        'sort_by': sort_by,
        'advanced_ajax_search': True,
        'suggestion': None,
        'extended_search_form': extended_search_form,
        'query_string': request.GET.urlencode(),
        'site_id': settings.SITE_ID
    }
    return render_to_response(template, context,
        context_instance=context_class(request))

def backup_search(locations, user=None):
    restaurants = Restaurant.on_site.with_friends_score_for(
        user
    ).filter(active=1).all()
    restaurants = restaurants.filter(location__in=locations).distinct()
    return restaurants

def restaurant_friends_score(restaurant, user):
    friends = user.get_profile().friends.all()
    if friends:
        friends_score = restaurant.friends_score = Score.objects.filter(
            review__restaurant=restaurant,
            review__active=True,
            review__user__in=friends).aggregate(
            overall=Avg('value'))['overall']
    else:
        friends_score = None

    return friends_score

def search_users(request):
    load_all = True
    form_class = SearchForm
    searchqueryset = SearchQuerySet()
    results_per_page = 10

    query = ''
    results = EmptySearchQuerySet()

    if request.GET.get('q'):
        get_values = request.GET.copy()
        get_values['q'] = escape(request.GET.get('q'))

        form = form_class(get_values,
            searchqueryset=searchqueryset, load_all=load_all)

        if form.is_valid():
            query = form.cleaned_data['q']
            results = [r for r in form.search()
                if r.content_type() == 'auth.user']
            if request.user.is_authenticated():
                friends = request.user.get_profile().friends.all()
                results = sorted(results,
                    key=lambda x:
                    (x.object not in friends, x.object.username))
    else:
        form = form_class(searchqueryset=searchqueryset, load_all=load_all)

    try:
        page = request.GET.get('page', 1)
    except PageNotAnInteger:
        page = 1

    paginator = Paginator(results, results_per_page, request=request)

    #BUG/WORKAROUND: for some reason search fails when it contains
    #special characters. Oddly this fixes it, I just don't know why.
    try:
        page = paginator.page(page)
    except:
        page = paginator

    context = {
        'form': form,
        'page': page,
        'paginator': paginator,
        'query': query,
        'suggestion': form.get_suggestion(),
        'site_id': settings.SITE_ID
    }

    if getattr(settings, 'HAYSTACK_INCLUDE_SPELLING', False):
        context['suggestion'] = form.get_suggestion()

    return render_to_response('search/users.html', context,
        context_instance=RequestContext(request))
