from celery.task import task
from celery.task.sets import TaskSet
from taste.apps.invite.utils import SendInvite

@task(ignore_result=True)
def send_to_contact(contact):
    SendInvite.by_address_book(contact)

@task(ignore_result=True)
def send_to_email(email, user=None, message=None):
    SendInvite.by_email(email, user, message)

@task(ignore_result=True)
def invite_via_address_book(contacts):
    subtasks = TaskSet(send_to_contact.subtask((contact,))
        for contact in contacts)
    subtasks.apply_async()

@task(ignore_result=True)
def invite_via_email(addresses, user=None, message=None):
    subtasks = TaskSet(send_to_email.subtask((email,user,message))
        for email in addresses)
    subtasks.apply_async()
