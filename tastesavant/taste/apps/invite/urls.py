from django.conf.urls.defaults import patterns, url

from taste.apps.invite.views import (google_request_auth,
    google_auth_complete, yahoo_request_auth, yahoo_auth_complete,
    invite_from_gmail_contacts, invite_from_yahoo_contacts, invite_from_facebook,
    invite_from_email)

from django.views.generic.simple import redirect_to

urlpatterns = patterns('',
    url(r'^$', redirect_to, {'url': 'email/'}),
    url(r'^auth/google/$', google_request_auth, name="invite_auth_google"),
    url(r'^auth/google/complete/$', google_auth_complete, name="google_auth_complete"),
    url(r'^auth/yahoo/$', yahoo_request_auth, name="invite_auth_yahoo"),
    url(r'^auth/yahoo/complete/$', yahoo_auth_complete, name="yahoo_auth_complete"),
    url(r'^gmail/$', invite_from_gmail_contacts, name="invite_from_gmail"),
    url(r'^yahoo/$', invite_from_yahoo_contacts, name="invite_from_yahoo"),
    url(r'^facebook/$', invite_from_facebook, name="invite_from_facebook"),
    url(r'^email/$', invite_from_email, name="invite_from_email"),
)
