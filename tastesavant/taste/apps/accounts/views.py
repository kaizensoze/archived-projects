from django.template import RequestContext
from django.shortcuts import render_to_response
from django.contrib.auth.decorators import login_required

# for custom django registration
from django.conf import settings
from registration.models import RegistrationProfile
from taste.apps.profiles.models import Profile
from taste.apps.profiles.utils import subscribe_to_mailchimp, send_welcome_email

@login_required
def account(request):
    """ Account view """
    return render_to_response("accounts/settings.html", {},
                              context_instance=RequestContext(request))

def activate(request, activation_key,
             template_name='registration/activate.html',
             extra_context=None):
    try:
        account = RegistrationProfile.objects.activate_user(activation_key)

    except RegistrationProfile.DoesNotExist:
        pass

    if account:
        profile, created = Profile.objects.get_or_create(user=account)

        # subscribe to mailchimp
        subscribe_to_mailchimp(account, 'User Sign Ups')

        # send welcome email
        send_welcome_email(account)

    if extra_context is None:
        extra_context = {}
    context = RequestContext(request)
    for key, value in extra_context.items():
        context[key] = callable(value) and value() or value
    return render_to_response(template_name, {'account': account,
            'expiration_days': settings.ACCOUNT_ACTIVATION_DAYS},
        context_instance=context)
