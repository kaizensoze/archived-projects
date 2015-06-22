from admin import FlatPageAdmin
from django.conf.urls.defaults import patterns, url, include
from django.contrib import admin
from django.contrib.auth.views import logout, password_reset
from django.contrib.flatpages.models import FlatPage
from django.contrib.sitemaps import GenericSitemap
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.views.generic.simple import direct_to_template
from django.views.static import serve
from registration.views import register
from taste.apps.restaurants.models import Restaurant
from taste.apps.accounts.forms import SignupForm
from taste.apps.accounts.views import activate
from taste.apps.homepage.views import (
    homepage,
    ajax_activity_feed,
    get_the_app
)
import os.path

admin.autodiscover()

DOCUMENT_ROOT = os.path.join(os.path.dirname(__file__), 'media')
handler500 = "taste.apps.lumberjack.views.server_error"

admin.site.unregister(FlatPage)
admin.site.register(FlatPage, FlatPageAdmin)

info_dict = {
    'queryset': Restaurant.objects.all(),
}

sitemaps = {
    'restaurants': GenericSitemap(info_dict, priority=0.6),
}

urlpatterns = patterns(
    '',
    url(r'^$', homepage, name='homepage'),
    url(r'^api/1/', include('taste.apps.api.urls')),
    url(
        r'^api-auth/',
        include('rest_framework.urls', namespace='rest_framework')
    ),

    # intercept some of the regular url routing so our
    # project specific args & view customizations take precedence.
    url(r'^accounts/register/$', register,
        {
            'form_class': SignupForm,
            'backend': 'registration.backends.default.DefaultBackend'
        },
        name='registration_register_signup'),

    url(r'^accounts/activate/(?P<activation_key>\w+)/$', activate,
        name='registration_activate'),

    url(r'^activity/$', ajax_activity_feed, name='ajax_activity'),
    (r'^accounts/', include('registration.urls')),
    (r'^admin/', include(admin.site.urls)),
    (r'^avatar/', include('avatar.urls')),
    (r'^blackbook/', include('blackbook.urls')),
    (r'^critic/', include('critics.urls')),
    (r'^media/(?P<path>.*)$', serve, {'document_root': DOCUMENT_ROOT}),
    (r'^messages/', include('taste.apps.usermessages.urls')),
    (r'^newsfeed/', include('newsfeed.urls')),
    (r'^press/', include('press.urls')),
    (r'^profiles/', include('profiles.urls')),
    (r'^invite/', include('invite.urls')),
    (r'^restaurant/', include('taste.apps.restaurants.urls')),
    (r'^search/', include('taste.apps.search.urls')),
    (r'^social/', include('social_auth.urls')),
    url(r'^get-the-app/$', get_the_app, name='get_the_app'),
    url(r'^coming-soon/$', direct_to_template,
        {'template': 'coming-soon.html'},
        name='comingsoon'),
    url(r'^logout/$', logout, {'next_page': '/'}, name='auth_logout'),
    url(r'^logout(?P<next_page>.*)$', logout, name='auth_logout_next'),
    (r'^sitemap\.xml$', 'django.contrib.sitemaps.views.sitemap',
        {'sitemaps': sitemaps}),
)

urlpatterns += staticfiles_urlpatterns()
