from django.shortcuts import render_to_response
from taste.apps.newsfeed.models import Activity
from django.template import RequestContext

def activity(request):
    context_dict = dict()
    request.user
    # This is clearly old, once used for testing.
    # I doubt this view is used at all.
    context_dict['newsfeed'] = Activity.objects.filter(user__username='nficano')
    template = 'newsfeed/list.html'
    return render_to_response(template, context_dict,
                              context_instance=RequestContext(request))
