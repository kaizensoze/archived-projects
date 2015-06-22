from django.forms import ModelChoiceField, ModelForm, SelectMultiple
from taste.apps.invite.models import Contact
from django.db.models import Count
from django import forms

class NameModelChoiceField(ModelChoiceField):
    def label_from_instance(self, obj):
        if not obj.name:
            return obj.email
        else:
            return "<strong>%s</strong> %s" % (obj.name, obj.email)

class ContactForm(ModelForm):
    class Meta:
        model = Contact
        exclude = ('user','added','users','name','email','provider')

    def __init__(self, user=None, *args, **kwargs):
        super(ContactForm, self).__init__(*args, **kwargs)
        self.fields['contacts'] = NameModelChoiceField(
            queryset=Contact.objects.filter(user=user).annotate(
                null_name=Count('name')).order_by('-null_name','name'),
            empty_label=None, widget=SelectMultiple)

class InviteByEmailForm(forms.Form):
    recipients = forms.CharField(label="Email Address", required=True)
    message = forms.CharField(label="Message", widget=forms.Textarea)
