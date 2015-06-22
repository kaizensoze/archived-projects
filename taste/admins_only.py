from django.conf import settings
from django.core.mail.backends import smtp


class EmailBackend(smtp.EmailBackend):
    def send_messages(self, messages, *args, **kwargs):
        for message in messages:
            message.to = [a[1] for a in settings.ADMINS]
        return super(EmailBackend, self).send_messages(messages, *args, **kwargs)
