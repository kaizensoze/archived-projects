from django.conf.urls.defaults import patterns, url

from taste.apps.profiles import views

urlpatterns = patterns('',
    url(r'^delete/$', views.delete_account, name='account_delete'),
    url(r'^create/$', views.create_profile, name='profiles_create_profile'),
    url(r'^edit/$', views.edit_profile, name='profiles_edit_profile'),
    url(r'^suggestions/$', views.follower_suggestions, name='follower_suggestions'),
    url(r'^link/$', views.link_accounts, name='link_accounts'),
    url(r'^(?P<username>[A-Za-z0-9- @._]+)/$', views.profile_detail, name='profiles_profile_detail'),
    url(r'^(?P<username>[A-Za-z0-9- @._]+)/followers/$', views.profile_detail_followers, name='profiles_profile_detail_followers'),
    url(r'^(?P<username>[A-Za-z0-9- @._]+)/following/$', views.profile_detail_following, name='profiles_profile_detail_following'),
    url(r'^edit/avatar/$', views.edit_avatar, name='profiles_edit_avatar'),
    url(r'^follow/(?P<username>[A-Za-z0-9- @._]+)/(?P<success_url>.{0,500})/$', views.follow, name='follow_user'),
    url(r'^unfollow/(?P<username>[A-Za-z0-9- @._]+)/(?P<success_url>.{0,500})/$', views.unfollow, name='unfollow_user'),
    url(r'^(?P<username>[A-Za-z0-9- @._]+)/friends$', views.ajax_friends, name='ajax_friends'),
    url(r'^(?P<username>[A-Za-z0-9- @._]+)/followers$', views.ajax_followers, name='ajax_followers'),
)
