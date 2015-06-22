from django.conf.urls.defaults import patterns, url

from taste.apps.blackbook import views

urlpatterns = patterns(
    '',
    url(
        r'^$',
        views.blackbook
    ),
    url(
        r'(?P<username>[^/]+)/$',
        views.blackbook_for_user,
        name='blackbook'
    ),
    url(
        r'^ajax/entry$',
        views.entry,
        name='ajax_entry'
    ),
    url(
        r'^ajax/collections/(?P<username>[A-Za-z0-9- @._]+)/$',
        views.CollectionListView.as_view(),
        name='ajax_collection'
    ),
)
