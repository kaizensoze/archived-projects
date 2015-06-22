from django.conf.urls.defaults import patterns, url

from .views import show_press

urlpatterns = patterns('',
    url(r'^$', show_press, name='press'),
)
