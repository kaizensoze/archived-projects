from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('taste.apps.newsfeed.views',
    url(r'^$', 'activity', name="recent-activity"),
)
