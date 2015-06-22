from datetime import (datetime, timedelta)

from celery.task import task
from django.core import management

from .models import (Restaurant, Occasion)


@task(ignore_result=True)
def rebuild_index():
    management.call_command('rebuild_index', interactive=False)


@task(ignore_result=True)
def no_longer_new_on_the_scene():
    new_on_the_scene = Occasion.objects.get(name='NEW on the scene')
    # Six months:
    offset = timedelta(days=(30 * 6))
    now = datetime.now()
    no_longer_new = Restaurant.objects.filter(
        added__lte=(now - offset),
        occasion=new_on_the_scene
    )
    for r in no_longer_new:
        r.occasion.remove(new_on_the_scene)
