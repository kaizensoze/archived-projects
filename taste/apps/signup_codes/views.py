from django.shortcuts import render_to_response
from django.template import RequestContext
from django.utils.translation import ugettext
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required

from taste.apps.signup_codes.models import check_signup_code
from taste.apps.signup_codes.forms import SignupForm, InviteUserForm


@login_required
def signup(request):
    code = ''
    code_valid = ''
    code_invalid = ''

    if request.method == "POST":
        form = SignupForm(request.user, request.POST)
        if form.is_valid():
            code = form.cleaned_data["code"]
            signup_code = check_signup_code(code)

            if signup_code:
                code_valid = True
                signup_code.use(request.user)
            else:
                code_invalid = True

    else:
        form = SignupForm()

    return render_to_response("account/signup_code.html", {
        "code": code,
        "code_valid": code_valid,
        "code_invalid": code_invalid,
        "form": form,
    }, context_instance=RequestContext(request))


@staff_member_required
def admin_invite_user(request, form_class=InviteUserForm,
        template_name="signup_codes/admin_invite_user.html"):
    """
    This view, by default, works inside the Django admin.
    """
    if request.method == "POST":
        form = form_class(request.POST)
        if form.is_valid():
            email = form.cleaned_data["email"]
            form.send_signup_code()
            request.user.message_set.create(message=ugettext("An e-mail has been sent to %(email)s.") % {"email": email})
            form = form_class() # reset
    else:
        form = form_class()
    return render_to_response(template_name, {
        "title": ugettext("Invite user"),
        "form": form,
    }, context_instance=RequestContext(request))
