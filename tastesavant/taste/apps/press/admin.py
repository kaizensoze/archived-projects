from django.contrib import admin
from .models import PressBadge


class PressBadgeAdmin(admin.ModelAdmin):
    pass


admin.site.register(PressBadge, PressBadgeAdmin)
