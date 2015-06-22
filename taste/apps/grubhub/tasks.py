from celery.task import task
from taste.apps.grubhub.utils import run_grubhub_sync


@task(ignore_result=True)
def update_all_grubhub_delivery_data():
    run_grubhub_sync()
