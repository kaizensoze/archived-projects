from django.contrib import admin
from taste.apps.singleplatform.models import Menu, Entry, Price


class MenuAdmin(admin.ModelAdmin):
    list_filter = ('restaurant__site',)


admin.site.register(Menu, MenuAdmin)
admin.site.register(Entry)
admin.site.register(Price)
