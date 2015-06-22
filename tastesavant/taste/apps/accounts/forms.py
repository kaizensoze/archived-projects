from django import forms
from django.contrib.auth.models import User
from django.core.mail import mail_managers
from django.utils.translation import ugettext_lazy as _

from registration.forms import RegistrationFormUniqueEmail


class SignupForm(RegistrationFormUniqueEmail):

    username = forms.RegexField(
        regex=r'^[\w.@+-]+$',
        max_length=30,
        widget=forms.TextInput(),
        label=_("Username"),
        error_messages={
            'invalid': _("This value may contain only letters, numbers and "
                         "@/./+/-/_ characters.")
        }
    )
    password1 = forms.CharField(
        label=_("Password"),
        widget=forms.PasswordInput(render_value=False)
    )
    password2 = forms.CharField(
        label=_("Password (again)"),
        widget=forms.PasswordInput(render_value=False)
    )
    email = forms.EmailField(widget=forms.TextInput())

    def send_notice_to_admins(self, email):
        mail_managers(
            "[Taste Savant] Duplicate email signup",
            """
Another user has tried to sign up with the email %s, but we already have
a user with that email.
            """ % email
        )

    def clean(self):
        if "password1" in self.cleaned_data and "password2" in self.cleaned_data:
            if self.cleaned_data["password1"] != self.cleaned_data["password2"]:
                raise forms.ValidationError(_("You must type the same password each time."))
        return self.cleaned_data

    def clean_email(self):
        if User.objects.filter(email__iexact=self.cleaned_data['email']).count():
            self.send_notice_to_admins(self.cleaned_data['email'])
        return super(SignupForm, self).clean_email()
