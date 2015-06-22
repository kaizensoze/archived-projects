from django.db import models
from django.template import Context, RequestContext, Template


class ActivityManager(models.Manager):
    def __init__(self):
        super(ActivityManager, self).__init__()
        self.context = Context()

    def set_request_context(self, request, **kwargs):
        self.context = RequestContext(request, **kwargs)

    def get_query_set(self):
        queryset = super(ActivityManager, self).get_query_set()
        queryset = queryset.order_by('-occurred')
        import IPython.Shell; IPython.Shell.IPShellEmbed(argv=[])()
        result_list = []
        for row in queryset:
            model = self.model(id=row.id, user=row.user, action=row.action)
            model.message = self.render_context(row._message)
            result_list.append(model)
        return result_list

    def render_context(self, template_string):
        """ A template renders a context by replacing the variable "holes"
        with values from the context and executing all block tags. """
        
        t = Template(template_string)
        return t.render(self.context)
