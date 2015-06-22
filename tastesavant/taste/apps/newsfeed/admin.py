from django.contrib import admin
from newsfeed.models import Action, Activity

import re

class ActionAdmin(admin.ModelAdmin):
    pass

class ActivityAdmin(admin.ModelAdmin):
    list_display = ("user","format_message", "occurred", "activity_id")
    list_filter = ['action']
    readonly_fields =['user','occurred','action', "meta_data","activity_id","restaurant"]

    def format_message(self, parser):
        return ("%s" % (self.remove_html_tags(parser.message).title()))
    format_message.short_description = "Message"

    def remove_html_tags(self, data):
        p = re.compile(r'<.*?>')
        return p.sub('', data)
    
admin.site.register(Action, ActionAdmin)
admin.site.register(Activity, ActivityAdmin)
