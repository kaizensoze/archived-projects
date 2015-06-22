from django.conf import settings
from django.contrib.sites.models import Site
from django.core.mail import EmailMultiAlternatives
from django.core.urlresolvers import reverse
from django.core.validators import email_re
from django.template.loader import render_to_string
from django.utils.encoding import smart_str
from django.utils.html import strip_tags
from gdata.auth import GenerateAuthSubUrl
from urllib import basejoin
from django.contrib.auth.models import User


def fullname(value):
    try:
        user = User.objects.get(username=value)
        profile = user.get_profile()

        if profile.first_name and profile.last_name:
            return profile.first_name + " " + profile.last_name
        elif user.first_name and user.last_name:
            return user.first_name + " " + user.last_name
        else:
            return value
    except:
        return value

class SendInvite:
    domain = Site.objects.get_current().domain
    from_email = settings.DEFAULT_FROM_EMAIL
    default_protocol = 'http'
    site_url = '%s://%s' % (default_protocol, domain)

    @classmethod
    def by_email(cls, email, user=None, message=None):
        obj = cls()
        obj.to_email = email
        if user:
            obj.user = user
        if message:
            obj.message = message
        obj.send_message()

    @classmethod
    def by_address_book(cls, contact):
        obj = cls()
        obj.user = contact.user
        obj.to_email = contact.email
        obj.send_message()

    @property
    def html_content(self):
        template_name = "invite/invitation-html.html"
        return self._message(template_name)

    @property
    def text_content(self):
        template_name = "invite/invitation-plain.html"
        return self._message(template_name)

    def _message(self, template_name):
        content = {'site_url': self.site_url}
        if hasattr(self, 'message'):
            content['message'] = strip_tags(self.message)
        if hasattr(self, 'user'):
            content['user'] = self.user.username
        return render_to_string(template_name, content)

    @property
    def subject(self):
        if hasattr(self, 'user'):
            return "%s has invited you to TasteSavant.com!" % fullname(
                self.user.username)
        else:
            return "You've been invited to TasteSavant.com!"

    def send_message(self):
        msg = EmailMultiAlternatives(self.subject, self.text_content,
            self.from_email, [self.to_email])
        msg.attach_alternative(self.html_content, "text/html")
        msg.send()

def parse_addresses(recipients):
    addresses = []
    recipients = smart_str(recipients).split(',')
    for email in recipients:
        email = email.strip()
        if email_re.match(email):
            addresses.append(email)
    return addresses

def callback_url(provider):
    try:
        base = settings.SITE_URL
    except:
        base = Site.objects.get_current().domain
    path = reverse("%s_auth_complete" % provider)
    if base.startswith('http://') is not True:
        base = 'http://' + base
    return basejoin(base, path)

def google_redirect_url():
    next_url = callback_url('google')
    scope = ' '.join(settings.GOOGLE_EXTENDED_PERMISSIONS)
    return GenerateAuthSubUrl(next_url, scope, secure=False, session=True)
