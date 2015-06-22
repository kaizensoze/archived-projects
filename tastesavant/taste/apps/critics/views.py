from pure_pagination import Paginator, InvalidPage, EmptyPage, PageNotAnInteger
from django.template import RequestContext
from django.shortcuts import get_object_or_404, render_to_response
from taste.apps.critics.models import Site
from taste.apps.reviews.models import Review


def critic(request, critic):
    template = 'critics/reviews.html'

    critic = get_object_or_404(Site, slug=critic)

    order = ''
    sort_key = request.GET.get('order', None)

    if sort_key:
        order = sort_key
        if sort_key == 'score':
            order_by = '-score'
        elif sort_key == 'restaurant':
            order_by = 'restaurant__name'
        else:
            order_by = '-special_sort_key'
    else:
        order_by = '-special_sort_key'

    reviews = Review.objects.filter(
        site=critic,
        restaurant__active=True
    ).with_special_sort_key(
    ).order_by(order_by)

    results_per_page = 20
    try:
        page = request.GET.get('page', 1)
    except PageNotAnInteger:
        page = 1

    if request.GET.get('display', None) == 'all':
        if reviews.count() <= 100:
            paginator = Paginator(reviews, 100, request=request)
            page = 1
        else:
            paginator = Paginator(reviews, results_per_page, request=request)
    else:
        paginator = Paginator(reviews, results_per_page, request=request)

    try:
        page = paginator.page(page)
    except (EmptyPage, InvalidPage):
        page = paginator.page(paginator.num_pages)

    data = {
        'critic': critic,
        'paginator': paginator,
        'page': page,
        'host': request.get_host(),
        'order': order
    }

    return render_to_response(template, data,
                              context_instance=RequestContext(request))
