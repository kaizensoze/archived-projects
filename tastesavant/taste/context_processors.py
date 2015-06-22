from django.conf import settings
from django.contrib.flatpages.models import FlatPage
from django.contrib.sites.models import Site

from taste.apps.search.forms import SearchForm
from taste.apps.tracking.models import Tag

import itertools


def keys(request):
    return {'GOOGLE_MAPS_KEY': getattr(settings, 'GOOGLE_MAPS_KEY', '')}


def flatpages(request):
    current_site = Site.objects.get_current()

    iosApp = FlatPage.objects.filter(sites=current_site, url='/iosApp/')
    pages = FlatPage.objects.filter(sites=current_site).exclude(url='/iosApp/')
    pages1 = itertools.chain(iosApp, pages[:7])
    pages2 = pages[7:]

    return {
        'pages1': pages1,
        'pages2': pages2
    }


def search(request):
    search_form = SearchForm()
    return {
        'search_form': search_form
    }


def tracking(request):
    tags = Tag.objects.filter(active=True)
    return {
        'tags': tags
    }


def current_path(request):
    return {
        'current_path': request.get_full_path()
    }


def current_city(request):
    return {
        'current_city': settings.CITIES[Site.objects.get_current().pk]
    }


def all_cities(request):
    current = Site.objects.get_current()
    others = Site.objects.exclude(pk__in=[1, current.pk]).order_by('name')
    return {
        'all_other_cities': others
    }


def current_city_lat_lng(request):
    return {
        'current_city_lat_lng':
        settings.LAT_LNG[settings.CITIES[Site.objects.get_current().pk]]
    }


def debug_setting(request):
    return {
        'debug_setting': settings.DEBUG
    }
