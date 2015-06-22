from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('taste.apps.critics.views',
    url(r'(?P<critic>[-\w\d]+)/$', 'critic', name="critic-reviews"),
)
