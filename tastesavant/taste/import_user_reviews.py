from apps.restaurants.models import Restaurant
from apps.reviews.models import Review, ReviewDish, Dish
from django.contrib.auth.models import User

import csv

IMPORT_FILE = ''
CURRENT_CITY = ''

with open(IMPORT_FILE) as f:
    reader = csv.reader(f)
    rows = [row for row in reader]

for row in rows[1:]:
    (
        restaurant_name,
        username,
        name,
        overall_score,
        food_score,
        ambiance_score,
        service_score,
        review,
        good_dishes,
        bad_dishes,
    ) = row
    try:
        restaurant = Restaurant.objects.get(
            name=restaurant_name,
            site__name=CURRENT_CITY
        )
    except:
        print "problem with restaurant {0}".format(restaurant_name)
        continue
    try:
        user = User.objects.get(username=username)
    except:
        print "problem with user {0}".format(username)
        continue
    try:
        overall_score = round(float(overall_score))
        food_score = round(float(food_score))
        ambiance_score = round(float(ambiance_score))
        service_score = round(float(service_score))
    except:
        pass
    r = Review.objects.create(
        restaurant=restaurant,
        user=user,
        overall_score=overall_score,
        food_score=food_score,
        ambience_score=ambiance_score,
        service_score=service_score,
        body=review,
        summary=review
    )
    for dish_name in good_dishes.split(','):
        dish_name = dish_name.strip()
        if dish_name:
            dish, created = Dish.objects.get_or_create(name=dish_name)
            ReviewDish.objects.create(review=r, dish=dish, recommended=True)
    for dish_name in bad_dishes.split(','):
        dish_name = dish_name.strip()
        if dish_name:
            dish, created = Dish.objects.get_or_create(name=dish_name)
            ReviewDish.objects.create(review=r, dish=dish, recommended=False)
