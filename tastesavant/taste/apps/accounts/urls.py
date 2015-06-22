from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('',
    url(r'^settings/$', 'taste.apps.accounts.views.account', name="account"),
)
