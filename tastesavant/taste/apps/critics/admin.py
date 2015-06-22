from django.contrib import admin

from taste.apps.critics.models import Author, Site

class AuthorAdmin(admin.ModelAdmin):
    search_fields = ('name',)
    list_filter = ('site',)

admin.site.register(Author, AuthorAdmin)
admin.site.register(Site)
