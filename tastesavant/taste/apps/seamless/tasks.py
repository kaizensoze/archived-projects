from celery.task import task
from taste.apps.seamless.utils import run_seamless_sync


@task(ignore_result=True)
def update_all_seamless_delivery_data():
    run_seamless_sync()
