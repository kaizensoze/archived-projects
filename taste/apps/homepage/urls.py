from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('taste.apps.homepage.views',
    url(r'^$', 'homepage', name="homepage")
)
