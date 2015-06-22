from django.contrib import admin

from taste.apps.comingsoon.models import Email

class EmailAdmin(admin.ModelAdmin):
    search_fields = ('address',)

admin.site.register(Email, EmailAdmin)
