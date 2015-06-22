from django.contrib import admin
from taste.apps.tracking.models import Tag

class TagAdmin(admin.ModelAdmin):
    model = Tag
    list_display = ('name', 'active',)

admin.site.register(Tag, TagAdmin)
