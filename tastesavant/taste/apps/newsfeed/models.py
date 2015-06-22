from django.contrib.auth.models import User
from django.core.serializers.json import DjangoJSONEncoder
from django.db import models
from django.template import Context, Template
from django.utils import simplejson as json
from django.utils.encoding import smart_str

from taste.apps.restaurants.models import Restaurant
from string import Template as StringTemplate
from hashlib import md5
from datetime import datetime


class Action(models.Model):
    """Preset templates for user activity messages
    """
    message = models.CharField(help_text="Message to appear in news feed",
                               max_length=255)
    action_name = models.CharField(null=True, blank=True, unique=True,
                                   max_length=16, help_text="""
        similar to url_name, its intended to make actions retrievable through
        some meaningful name""")
    description = models.CharField(null=True, blank=True, max_length=255,
                                   help_text="""
        Internal notes for an action (e.g.: triggers, purpose, etc).""")
    is_custom = models.BooleanField(default=False, help_text="""Designates
        whether this action is reusable or specific to a user.""")
    is_public = models.BooleanField(default=True)
    includes_context = models.BooleanField(
        default=False, help_text="""Does message provide its own context,
        (e.g.: `Nick has checked into Starbucks` v.s. `has checked into
        Starbucks`)""")

    def __unicode__(self):
        return self.action_name


class Activity(models.Model):
    """The users activity for news feed
    """
    user = models.ForeignKey(User)
    occurred = models.DateTimeField(default=datetime.now, blank=True)
    action = models.ForeignKey(Action)
    meta_data = models.TextField(null=True, blank=True)
    restaurant = models.ForeignKey(Restaurant, null=True, blank=True)
    activity_id = models.CharField(unique=True, max_length=255, null=True,
                                   blank=True)

    class Meta:
        verbose_name_plural = 'Activities'

    # @note: Consider making a static method? --kit
    def deserialize(self, json_string):
        """ Deserializes the JSON metadata to a dictionary """
        if json_string == "":
            return None
        try:
            return json.loads(json_string)
        except ValueError:
            pass
        return json_string

    @property
    def metadata(self):
        return self.deserialize(self.meta_data)

    def _render_django_context(self, template_string):
        """ A template renders a context by replacing the variable "holes"
        with values from the context and executing all block tags. """
        t = Template(template_string)
        c = Context()

        return t.render(c)

    def _render_metadata_context(self):
        """ Map keys in the meta data to their identifiers in the context of
        the action template. """

        template_string = self.action.message
        template_string = smart_str(template_string)
        tpl = StringTemplate(template_string)

        if isinstance(self.metadata, dict):
            message = tpl.substitute(self.metadata)
            return message

    @property
    def message(self):
        """ The action message with only the metadata rendered """
        if self.action.message and self.metadata:
            message = self._render_metadata_context()
            #message = self._render_django_context(message)
            return message

    def save(self, *args, **kwargs):
        """ Serializes the metadata to JSON prior to writing it to
        the database """

        if isinstance(self.meta_data, dict):
            try:
                self.meta_data = json.dumps(self.meta_data,
                                            cls=DjangoJSONEncoder)
            except:
                pass

        if self.action.action_name == 'follow':
            md5_hash = md5()
            md5_hash.update(self.user.username)
            md5_hash.update(self.meta_data)
            self.activity_id = md5_hash.hexdigest()

        if self.action.action_name == 'checkin':
            md5_hash = md5()
            md5_hash.update(self.user.username)
            md5_hash.update(self.occurred.isoformat())
            md5_hash.update(str(self.restaurant.id))
            self.activity_id = md5_hash.hexdigest()

        if self.action.action_name == 'reviewed':
            md5_hash = md5()
            md5_hash.update(self.user.username)
            md5_hash.update(self.occurred.isoformat())
            md5_hash.update(self.meta_data)
            md5_hash.update(str(self.restaurant.id))
            self.activity_id = md5_hash.hexdigest()

        if self.action.action_name == 'blackbook':
            md5_hash = md5()
            md5_hash.update(self.user.username)
            md5_hash.update(self.occurred.isoformat())
            md5_hash.update(self.meta_data)
            md5_hash.update(str(self.restaurant.id))
            self.activity_id = md5_hash.hexdigest()

        if Activity.objects.filter(activity_id=self.activity_id).count():
            return
        else:
            super(Activity, self).save(*args, **kwargs)

    def __unicode__(self):
        return self.action.message
