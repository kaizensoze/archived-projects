from django.contrib import admin
from taste.apps.invite.models import Contact

class ContactAdmin(admin.ModelAdmin):
    list_display = ('user', 'name', 'email',)
    list_filter = ('user',)

admin.site.register(Contact, ContactAdmin)
