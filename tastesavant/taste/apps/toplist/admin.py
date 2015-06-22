from django.contrib import admin
from taste.apps.toplist.models import TopList, TopListEntry

class TopListEntryInline(admin.TabularInline):
    model = TopListEntry
    extra = 1

class TopListAdmin(admin.ModelAdmin):
    model = TopList
    list_display = ('name', 'active',)
    inlines = [TopListEntryInline]

admin.site.register(TopList, TopListAdmin)
