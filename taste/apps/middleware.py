"""
Here's some custom middleware.

We want to direct users based on their GeoIP data to the appropriate sub-site
for the city they're in, but only some of the time.

Specifically:

If they're going to a particular restaurant or review link, send them to the
subdomain for that restaurant's city.

If they're going anywhere else, check if they have a default-city cookie. If
so, honor it.

If not, check GeoIP data. If they're in a city we have, route them there. If
not, route them to NYC.

If they go to a subdomain, don't reroute them.
"""

from math import radians, sin, cos, atan2, sqrt
from urllib import urlencode

from django.conf import settings
from django.contrib.gis.utils import GeoIP
from django.contrib.sites.models import Site
from django.http import HttpResponseNotFound, HttpResponseRedirect
from django.shortcuts import get_object_or_404
from django.core.urlresolvers import reverse

from honeypot.decorators import verify_honeypot_value
from honeypot.middleware import HoneypotResponseMiddleware

from taste.apps.restaurants.models import Restaurant

def geo_distance_in_mi(lat1, lon1, lat2, lon2):
    """
    Returns distance between one lat/long set and another in miles.
    """
    R = 6371  # km
    dLat = radians(lat2 - lat1)
    dLon = radians(lon2 - lon1)
    lat1 = radians(lat1)
    lat2 = radians(lat2)
    a = (
        sin(dLat / 2) *
        sin(dLat / 2) +
        sin(dLon / 2) *
        sin(dLon / 2) *
        cos(lat1) *
        cos(lat2)
    )
    return (R * (2 * atan2(sqrt(a), sqrt(1 - a)))) * 0.621371


def distance_within_geoip_radius(lat1, lon1, lat2, lon2, radius):
    return geo_distance_in_mi(lat1, lon1, lat2, lon2) <= radius


class CustomGeoIPMiddleware(object):
    def process_view(self, request, view_func, view_args, view_kwargs):
        requested_host = request.get_host()
        if (request.path.startswith('/restaurant')
                and not requested_host.startswith('localhost')):
            restaurant = get_object_or_404(
                Restaurant,
                slug=view_kwargs['restaurant']
            )
            current_site = Site.objects.get_current()
            if restaurant.site != current_site:
                redirect = "http://%s%s" % (
                    restaurant.site.domain,
                    request.path
                )
                return HttpResponseRedirect(redirect)

    def process_request(self, request):
        # If you are asking for the API, honor that:
        if request.path.startswith('/api'):  # and request.is_secure():
            return None
        # We only serve the API over HTTPS. We disavow knowledge of it
        # otherwise.
        if request.path.startswith('/api'):  # and not request.is_secure():
            return HttpResponseNotFound()
        # If you requested a subdomain, honor that.
        # (pk=1 is the root site, the one that redirects.)
        if Site.objects.get_current().pk != 1:
            return None
        # If you requested a restaurant page, honor that.
        if request.path.startswith('/restaurant'):
            return None
        requested_host = request.get_host()
        # The cookie logic will wait until a later phase of testing
        # We will need to determine when and how this cookie is set.
        #if 'preferred_site' in request.COOKIES:
        #    val = request.COOKIES.get('preferred_site')
        #    return
        if request.META.get('HTTP_X_FORWARDED_FOR', None):
            g = GeoIP()
            # If we can tell where you're asking from, respond based on that.
            addr = request.META['HTTP_X_FORWARDED_FOR'].split(',')[0].strip()
            try:
                # Yes, it returns them in that order.
                lon1, lat1 = g.coords(addr)
            except TypeError:
                # We get this error if g.coords returns None, most likely
                # meaning that the address it was given was non-routable. This
                # implies a misconfiguration and shouldn't happen, but if it
                # does, I'd rather we handle it gracefully than server-error.
                site = Site.objects.get(name='New York')
                redirect = "http://%s%s" % (site.domain, request.path)
                return HttpResponseRedirect(redirect)

            for k, v in settings.CITIES.items():
                # If your city is in our CITIES settings and isn't the first
                # one...
                lat2, lon2 = map(float, settings.LAT_LNG[v])
                radius = settings.GEOIP_RADIUS[v]
                close = distance_within_geoip_radius(
                    lat1,
                    lon1,
                    lat2,
                    lon2,
                    radius
                )
                if k != 1 and close:
                    # Redirect you there.
                    site = Site.objects.get(pk=k)
                    redirect = "http://%s%s" % (site.domain, request.path)
                    # Sanity check:
                    if site.domain == requested_host:
                        return None
                    return HttpResponseRedirect(redirect)
        # Otherwise, redirect you to the New York Site.
        site = Site.objects.get(name='New York')
        redirect = "http://%s%s" % (site.domain, request.path)
        # Sanity check:
        if (site.domain == requested_host
                or requested_host.startswith('localhost')):
            return None
        return HttpResponseRedirect(redirect)


class RedirectIfMobileMiddleware(object):
    """
    This assumes that the custom Minidetector middleware has already been run.
    """
    def process_request(self, request):
        should_redirect = (
            getattr(request, 'is_ios_device', False)
            and request.path != reverse('get_the_app')
            and 'mobile_splashed' not in request.COOKIES
            and not request.path.startswith('/api')
        )
        if should_redirect:
            return HttpResponseRedirect('{path}?{query}'.format(
                path=reverse('get_the_app'),
                query=urlencode({'next': request.path})
            ))
        else:
            return None  # I like to be explicit about this.


class CustomHoneypotViewMiddleware(object):
    """
        Middleware that verifies a valid honeypot on all non-ajax POSTs.
    """
    def process_view(self, request, callback, callback_args, callback_kwargs):
        if request.path.startswith('/api'):
            return None
        if request.is_ajax():
            return None
        return verify_honeypot_value(request, None)


class CustomHoneypotMiddleware(
        CustomHoneypotViewMiddleware,
        HoneypotResponseMiddleware):
    """
        Combines HoneypotViewMiddleware and HoneypotResponseMiddleware.
    """
    pass
