from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('taste.apps.comingsoon.views',
    url(r'^$', 'welcome', name="moderation-directory"),
)
