from django.shortcuts import render_to_response
from django.template import RequestContext

from taste.apps.userfiles.models import File
from taste.apps.comingsoon.models import Options
from taste.apps.comingsoon.forms import EmailForm

def welcome(request):
    options = Options()

    try:
        logo = File.objects.get(id = options.logo)
    except File.DoesNotExist:
        logo = None

    copy = options.copy
    thanks = options.thanks

    if request.method == 'GET':
        form = EmailForm()
    if request.method == 'POST':
        form = EmailForm(request.POST)
        if form.is_valid():
            form.save()
        return render_to_response('comingsoon/thanks.html', {'logo':logo, 'thanks':thanks},
            context_instance=RequestContext(request))
    return render_to_response('comingsoon/welcome.html', {'form':form, 'copy':copy, 'logo':logo},
        context_instance=RequestContext(request))
