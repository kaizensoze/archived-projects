from avatar.util import get_primary_avatar
from django.contrib.auth.decorators import login_required
from django.db.models import Q
from django.http import HttpResponse, Http404
from django.shortcuts import get_object_or_404
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.utils import simplejson as json
from django_messages.forms import ComposeForm
from django_messages.models import Message
from taste.apps.profiles.models import Profile

import datetime

@login_required
def inbox(request, template_name='messages/inbox.html'):
    message_list = Message.objects.inbox_for(request.user)
    return render_to_response(template_name, {
            'message_list': message_list,
            'compose_form': ComposeForm
            }, context_instance=RequestContext(request))

@login_required
def outbox(request, template_name='messages/outbox.html'):
    message_list = Message.objects.outbox_for(request.user)
    return render_to_response(template_name, {
            'message_list': message_list,
            'compose_form': ComposeForm,
            'outbox': 'active',
            }, context_instance=RequestContext(request))

@login_required
def trash(request, template_name='messages/trash.html'):
    message_list = Message.objects.trash_for(request.user)
    return render_to_response(template_name, {
            'message_list': message_list,
            'compose_form': ComposeForm,
            'trash': 'active',
            }, context_instance=RequestContext(request))

@login_required
def view(request, message_id, template_name='messages/view.html'):
    context = {}
    user = request.user
    now = datetime.datetime.now()
    message = get_object_or_404(Message, id=message_id)
    if message.sender == user:
        context['outbox'] = 'active'
    else:
        context['inbox'] = 'active'
    if (message.sender != user) and (message.recipient != user):
        raise Http404
    if message.read_at is None and message.recipient == user:
        message.read_at = now
        message.save()

    context['message'] = message
    context['compose_form'] = ComposeForm

    return render_to_response(template_name, context,
        context_instance=RequestContext(request))

def lookup_contact(request, template_name='messages/ajax_contact_lookup.html'):
    if request.GET.get('q', None):
        q = request.GET['q']
        friends = request.user.get_profile().friends.all()
        profiles = Profile.objects.filter(user__in=friends
                                          ).select_related('user')

        sqs = profiles.filter(Q(first_name__startswith=q)|
                  Q(last_name__startswith=q)|Q(user__username__startswith=q))[:5]

        if sqs:
            items = []
            vals = sqs.values('first_name','last_name','user__username')
            for v in vals:
                avatar = get_primary_avatar(v['user__username'], 30)
                try:
                    url = avatar.avatar_url(30)
                except AttributeError:
                    url = "/media/images/profile-default-30px-30px.png"
                user = v['user__username']
                first_name = v['first_name']
                last_name = v['last_name']
                if not first_name and not last_name:
                    first_name = user
                items.append({'user': user, 'first_name': first_name, 'last_name': last_name, 'url': url})
            data = json.dumps(items)
            return HttpResponse(content=data, status=200, content_type='application/json')
        else:
            return HttpResponse(content='', status=204)
    else:
        return HttpResponse(content='', status=204)
