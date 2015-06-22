from taste.apps.reviews.models import Review, Score

for review in Review.objects.all():
    if review.overall_score and review.overall_score != review.score.value:
        score = Score.objects.get(value=review.overall_score)
        review.score = score
        review.save()
        print "%s was out of sync" % review.id
    if review.overall_score is None and review.score.value:
        review.overall_score = review.score.value
        review.save()
        print "%s had no overall_score" % review.id
