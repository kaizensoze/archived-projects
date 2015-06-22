from django import forms
from django.contrib import admin, messages
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from django.contrib.flatpages.models import FlatPage
from django.utils.translation import ugettext_lazy as _
from django.utils.safestring import mark_safe

from admin_actions import export_as_csv_action


class CKEditor(forms.Textarea):
    class Media:
        js = ('js/ckeditor/ckeditor.js',)

    def render(self, name, value, attrs=None):
        rendered = super(CKEditor, self).render(name, value, attrs)
        return rendered + mark_safe(u'''<script type="text/javascript">
        //<![CDATA[

            // Replace the <textarea id="editor"> with an CKEditor
            // instance, using default configurations.
            CKEDITOR.replace( 'id_%s' );
        //]]>
        </script>
        <style>
        .%s label{
            float:none!important;
            }
        </style>
        ''' % (name, name))


class FlatpageForm(forms.ModelForm):
    url = forms.RegexField(
        label=_("URL"),
        max_length=100,
        regex=r'^[-\w/]+$',
        help_text=_("Example: '/about/contact/'. Make sure to have leading"
                    " and trailing slashes."),
        error_message=_("This value must contain only letters, numbers,"
                        " underscores, dashes or slashes.")
    )

    content = forms.CharField(widget=CKEditor())

    class Meta:
        model = FlatPage


class FlatPageAdmin(admin.ModelAdmin):
    form = FlatpageForm
    fieldsets = (
        (
            None,
            {'fields': ('url', 'title', 'content', 'sites')}
        ),
        (
            _('Advanced options'),
            {
                'classes': ('collapse',),
                'fields': (
                    'enable_comments',
                    'registration_required',
                    'template_name'
                )
            }
        ),
    )
    list_display = ('url', 'title')
    list_filter = ('sites', 'enable_comments', 'registration_required')
    search_fields = ('url', 'title')


# Customize Users in admin!
def _toggle_activation(modeladmin, request, queryset, active):
    try:
        rows_updated = queryset.update(is_active=active)
    except Exception as e:
        modeladmin.message_user(request, "Error: %s" % e, messages.ERROR)
    else:
        modeladmin.message_user(request, "%s user(s) updated." % rows_updated)


def activate(modeladmin, request, queryset):
    _toggle_activation(modeladmin, request, queryset, True)

activate.short_description = "Activate"


def deactivate(modeladmin, request, queryset):
    _toggle_activation(modeladmin, request, queryset, False)

deactivate.short_description = "Deactivate"

UserAdmin.actions = (
    activate,
    deactivate,
)
UserAdmin.list_display = (
    'username',
    'email',
    'first_name',
    'last_name',
    'is_active',
    'is_staff',
    'date_joined',
)

admin.site.unregister(User)
admin.site.register(User, UserAdmin)
