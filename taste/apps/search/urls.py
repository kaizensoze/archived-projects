from django.conf.urls.defaults import patterns, url
from taste.apps.search.views import (basic_search, advanced,
    auto_complete_search, auto_complete_user_search, search_users, ajax_search,
    advanced_ajax_search)

urlpatterns = patterns('',
    url(r'^ajax/$', ajax_search, name='ajax_search'),
    url(r'^advanced-ajax/$', advanced_ajax_search, name='advanced_ajax_search'),
    url(r'^$', basic_search, name='search'),
    url(r'^users/$', search_users, name='search_users'),
    url(r'^advanced/$', advanced, name='advanced_search'),
    url(r'^autocomplete/$', auto_complete_search, name='auto_complete_search'),
    url(r'^user-autocomplete/$', auto_complete_user_search,
        name='auto_complete_user_search'),
)
