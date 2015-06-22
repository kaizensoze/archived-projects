from apps.reviews.models import Dish, ReviewDish

from django.db.models import Count

from collections import defaultdict

dishes = defaultdict(set)


def canonicalize(dishes_set):
    dishes_list = list(dishes_set)
    first = dishes_list[0]
    all_but_first = dishes_list[1:]
    for rd in ReviewDish.objects.filter(dish__in=all_but_first):
        rd.dish = first
        rd.save()


for d in Dish.objects.all():
    dishes[d.name.lower()].add(d)


for k, v in dishes.items():
    if len(v) > 1:
        canonicalize(v)


Dish.objects.annotate(
    reviewdish_count=Count('reviewdish')
).filter(
    reviewdish_count=0
).delete()
