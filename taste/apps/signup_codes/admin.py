from django.contrib import admin

from taste.apps.signup_codes.models import SignupCode, SignupCodeResult

class SignupCodeAdmin(admin.ModelAdmin):
    list_display = ("code", "max_uses", "use_count", "expiry", "created")
    list_filter = ("created",)

class SignupCodeResultAdmin(admin.ModelAdmin):
    list_display = ("signup_code", "user", "timestamp")
    list_filter = ("signup_code",)

admin.site.register(SignupCode, SignupCodeAdmin)
admin.site.register(SignupCodeResult, SignupCodeResultAdmin)
