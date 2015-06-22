from apps.reviews.models import Dish
import csv

rows = []

for dish in Dish.objects.all():
    reviews = [r.review.id for r in dish.reviewdish_set.all()]
    rows.append([str(dish)] + reviews)

with open('dishes.csv', 'w') as f:
    csvwriter = csv.writer(f)
    for row in rows:
        csvwriter.writerow(row)
