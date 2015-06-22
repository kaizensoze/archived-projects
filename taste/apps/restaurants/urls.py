from django.conf.urls.defaults import patterns, url

urlpatterns = patterns('taste.apps.restaurants.views',
    url(r'(?P<restaurant>[-\w\d]+)/review/(?P<review>\w+)/$', 'restaurant', name="restaurant-review"),
    url(r'(?P<restaurant>[-\w\d]+)/menu/$', 'menu', name="restaurant-menu"),
    url(r'(?P<restaurant>[-\w\d]+)/$', 'restaurant', name="restaurant-detail"),
)
