from django.contrib.auth.decorators import login_required
from django.http import HttpResponse, Http404
from django.shortcuts import render_to_response, get_object_or_404
from django.template import RequestContext
from django.contrib.auth.models import User
from django.views.generic import (
    DetailView,
    ListView,
)

from .forms import (
    CollectionForm,
    EntryForm,
)
from .models import (
    Collection,
    Entry,
)


def blackbook_for_user(request, username):
    user = get_object_or_404(User, username=username)
    return render_to_response(
        'blackbook/backbone.html',
        {
            'blackbook_user': user
        },
        context_instance=RequestContext(request)
    )


class CollectionListView(ListView):
    context_object_name = "collections"
    model = Collection
    template_name = "blackbook/_collection_list.html"

    def get_queryset(self, *args, **kwargs):
        return self.model.objects.filter(
            user__username=self.kwargs['username']
        )


class CollectionInstanceView(DetailView):
    pass


@login_required
def blackbook(request, user=None):
    template = 'blackbook/detail.html'
    data = {}

    if user is None:
        user = request.user
        data['collections'] = Collection.objects.filter(user=user)[:4]
        data['empty_collections'] = 4 - len(data['collections'])

    return render_to_response(template, data,
                              context_instance=RequestContext(request))


@login_required
def entry(request):
    user = request.user

    # delete
    if request.method == 'DELETE':
        try:
            pk = request.GET['id']
            Entry.objects.get(pk=pk, collection__user=user).delete()
        except:
            raise Http404

    # update
    elif request.method == 'PUT':
        try:
            e = Entry.objects.get(pk=request.GET['id'], collection__user=user)
            form = EntryForm(collection=e.collection, data=request.POST)

            if form.is_valid():
                entry = form.cleaned_data['entry']
                e.entry = entry
                e.save()
                return HttpResponse('OK')
            else:
                raise Http404
        except:
            raise Http404

    # create
    elif request.method == 'POST':
        c = Collection.objects.get(
            pk=request.POST['collection'], user=request.user)
        form = EntryForm(data=request.POST, collection=c)
        if form.is_valid():
            pk = form.save()
            return HttpResponse(unicode(pk))
        else:
            raise Http404
    else:
        raise Http404


@login_required
def collection(request):
    user = request.user

    # create
    if request.method == 'POST':
        form = CollectionForm(user=user, data=request.POST)
        if form.is_valid():
            form.save()
            return HttpResponse('OK')
        else:
            return HttpResponse('FAIL')

    # delete
    elif request.method == 'DELETE':
        try:
            pk = request.GET['id']
            Collection.objects.get(pk=pk, collection__user=user).delete()
            return HttpResponse('OK')
        except:
            raise Http404
    else:
        raise Http404
