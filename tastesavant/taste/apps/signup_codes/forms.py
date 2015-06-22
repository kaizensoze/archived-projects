from datetime import datetime, timedelta

from django import forms
from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.hashcompat import sha_constructor
from django.utils.translation import ugettext

from django.contrib.sites.models import Site

# from taste.apps.account.forms import SignupForm as BaseSignupForm
from taste.apps.signup_codes.models import SignupCode, check_signup_code


class SignupForm(forms.ModelForm):
    code = forms.CharField(max_length=40, required=False, widget=forms.TextInput(attrs={"size": 60}))

    def clean_signup_code(self):
        # code = self.cleaned_data.get("signup_code")
        code = self.cleaned_data.get("code")
        signup_code = check_signup_code(code)
        if signup_code:
            return signup_code
        else:
            raise forms.ValidationError("Signup code was not valid.")

    def __init__(self, user=None, *args, **kwargs):
        self.user = user
        super(SignupForm, self).__init__(*args, **kwargs)

    class Meta:
        model = SignupCode
        fields = ('code',)


class InviteUserForm(forms.Form):
    email = forms.EmailField()

    def create_signup_code(self, commit=True):
        email = self.cleaned_data["email"]
        expiry = datetime.now() + timedelta(hours=1)
        code = sha_constructor("%s%s%s%s" % (
            settings.SECRET_KEY,
            email,
            str(expiry),
            settings.SECRET_KEY,
        )).hexdigest()
        signup_code = SignupCode(code=code, email=email, max_uses=1, expiry=expiry)
        if commit:
            signup_code.save()
        return signup_code

    def send_signup_code(self):
        email = self.cleaned_data["email"]
        signup_code = self.create_signup_code()

        current_site = Site.objects.get_current()
        domain = unicode(current_site.domain)

        subject = ugettext("Create an acccount on %(domain)s") % {"domain": domain}
        message = render_to_string("signup_codes/invite_user.txt", {
            "signup_code": signup_code,
            "domain": domain,
        })
        send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, [email], priority="high")

