import csv

from django.contrib import admin
from django.contrib.auth.models import User
from django.contrib.auth.admin import UserAdmin
from django.http import HttpResponse

from taste.apps.profiles.models import Profile

class ProfileAdmin(admin.ModelAdmin):
    search_fields = ('user__username', )
    list_display = (
        'user',
        'signed_up_via_app',
    )

admin.site.register(Profile, ProfileAdmin)


class ProfileInline(admin.StackedInline):
    model = Profile

class UserProfileAdmin(UserAdmin):
    list_display = UserAdmin.list_display + ('mobile_activity',)

    def mobile_activity(self, obj):
        return Profile.objects.get(user=obj).signed_up_via_app
    mobile_activity.boolean = True

    inlines = [ProfileInline,]

    actions = ['user_export_as_csv']

    def user_export_as_csv(self, request, queryset):
        opts = self.model._meta
        field_names = set([field.name for field in opts.fields]) - set(['password'])
        
        response = HttpResponse(mimetype='text/csv')
        response['Content-Disposition'] = (
            'attachment; filename={filename}.csv'.format(
                filename=unicode(opts).replace('.', '_')
            )
        )

        writer = csv.writer(response)

        header_fields = list(field_names)
        header_fields.extend(['preferred_site', 'signed_up_via_app'])
        writer.writerow(header_fields)

        for obj in queryset:
            cols = [unicode(getattr(obj, field)).encode("utf-8", "replace") for field in field_names]
            profile = Profile.objects.get(user=obj)
            cols.append(profile.preferred_site)
            cols.append(profile.signed_up_via_app)
            print(cols)
            writer.writerow(cols)
        return response
    user_export_as_csv.short_description='Export selected objects as CSV file'

admin.site.unregister(User)
admin.site.register(User, UserProfileAdmin)
