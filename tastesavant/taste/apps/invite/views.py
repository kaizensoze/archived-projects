from django.conf import settings
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect, Http404, HttpResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from social_auth.models import UserSocialAuth
from taste.apps.invite import tasks
from taste.apps.invite.forms import ContactForm, InviteByEmailForm
from taste.apps.invite.models import Contact
from taste.apps.invite.utils import parse_addresses, google_redirect_url, \
    SendInvite, callback_url
from taste.apps.invite.yahoo.application import OAuthApplication
from taste.apps.invite.yahoo.oauth import RequestToken
from urlparse import parse_qs

import importer

def has_facebook_social_auth(user):
    if user.is_authenticated():
        for auth in user.social_auth.all():
            if auth.provider == 'facebook':
                return auth
    return None

@login_required
def yahoo_request_auth(request):
    key = settings.YAHOO_CONSUMER_KEY
    secret = settings.YAHOO_CONSUMER_SECRET
    app_id = settings.YAHOO_APP_ID
    url = callback_url('yahoo')

    if not UserSocialAuth.objects.filter(user=request.user, provider='yahoo'):
        ydata = OAuthApplication(key, secret, app_id, url)
        request_token = ydata.get_request_token(url)
        request.session['request_token'] = request_token.to_string()

        # Redirect user to authorization url
        redirect_url = ydata.get_authorization_url(request_token)
        return HttpResponseRedirect(redirect_url)
    else:
        return HttpResponseRedirect(reverse("invite_from_yahoo"))

def yahoo_auth_complete(request):
    key = settings.YAHOO_CONSUMER_KEY
    secret = settings.YAHOO_CONSUMER_SECRET
    app_id = settings.YAHOO_APP_ID
    url = callback_url('yahoo')
    ydata = OAuthApplication(key, secret, app_id, url)

    if 'oauth_token' and 'oauth_verifier' in request.GET:
        verifier = request.GET['oauth_verifier']
        if not request.user.is_authenticated():
            return HttpResponse("")
        else:
            request_token_str = request.session['request_token']
            request_token = RequestToken.from_string(request_token_str)
            access_token = ydata.get_access_token(request_token, verifier)
            extra = parse_qs(access_token.to_string())
            uid = extra.get('xoauth_yahoo_guid')[0]
            auth, created = UserSocialAuth.objects.get_or_create(
                user=request.user, provider='yahoo',
                defaults={'uid': uid, 'extra_data': extra})
            contacts = ydata.getContacts()
            importer.import_yahoo(contacts, request.user)
        return HttpResponseRedirect(reverse("invite_from_yahoo"))
    else:
        return HttpResponse("")

@login_required
def invite_from_yahoo_contacts(request):
    if request.method == 'POST':
        invite_contacts = request.POST.getlist('contacts')
        contacts = [
            Contact.objects.get(id=contact) for contact in invite_contacts
        ]

        if settings.DEBUG:
            for contact in contacts:
                SendInvite.by_address_book(contact)
        else:
            tasks.invite_via_address_book.delay(contacts)
        messages.success(request, 'Your invitations have been sent!')
        return HttpResponseRedirect(reverse('invite_from_yahoo'))
    context = {
        'form': ContactForm(user=request.user),
        'has_facebook_auth': has_facebook_social_auth(request.user)
    }
    return render_to_response('invite/yahoo.html', context,
        context_instance=RequestContext(request))

@login_required
def google_request_auth(request):
    if not UserSocialAuth.objects.filter(user=request.user, provider='google'):
        url = google_redirect_url()
        return HttpResponseRedirect(url)
    else:
        return HttpResponseRedirect(reverse("invite_from_gmail"))

@login_required
def invite_from_gmail_contacts(request):
    if request.method == 'POST':
        invite_contacts = request.POST.getlist('contacts')
        contacts = [
            Contact.objects.get(id=contact) for contact in invite_contacts
        ]

        if settings.DEBUG:
            for contact in contacts:
                SendInvite.by_address_book(contact)
        else:
            tasks.invite_via_address_book.delay(contacts)

        messages.success(request, 'Your invitations have been sent!')
        return HttpResponseRedirect(reverse('invite_from_gmail'))
    context = {
        'form': ContactForm(user=request.user),
        'has_facebook_auth': has_facebook_social_auth(request.user)
    }
    return render_to_response('invite/gmail.html', context,
                              context_instance=RequestContext(request))

def invite_from_email(request):
    if request.method == 'POST':
        user = None
        message = None
        form = InviteByEmailForm(request.POST)
        if form.is_valid():
            recipients = form.cleaned_data['recipients']
            message = form.cleaned_data['message']
            addresses = parse_addresses(recipients)

            if request.user.is_authenticated():
                user = request.user

            if settings.DEBUG:
                for email in addresses:
                    SendInvite.by_email(email, user, message)
            else:
                tasks.invite_via_email.delay(addresses, user, message)

            messages.success(request, 'Your invitations have been sent!')
            return HttpResponseRedirect(reverse('invite_from_email'))
    else:
        form = InviteByEmailForm()

    return render_to_response('invite/email.html',
        {'form': form, 'has_facebook_auth': has_facebook_social_auth(request.user)},
        context_instance=RequestContext(request))

@login_required
def google_auth_complete(request):
    if 'token' in request.GET:
        string_token = str(request.GET['token'])
        obj, created = UserSocialAuth.objects.get_or_create(user=request.user,
                           provider='google', defaults={'uid':string_token})
        importer.import_google(string_token, request.user)
        return HttpResponseRedirect(reverse("invite_from_gmail"))
    else:
        raise Http404


@login_required
def invite_from_facebook(request):
    context = {
        'has_facebook_auth': has_facebook_social_auth(request.user)
    }
    return render_to_response('invite/facebook.html', context,
        context_instance=RequestContext(request))
