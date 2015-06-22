import re
from django import template
from django.contrib.auth.models import User

register = template.Library()


@register.filter
def is_this_me(value, user):
    href_r = re.compile('href="(.*)".*>(.*)<')
    if href_r.search(value):
        path, human_name = href_r.search(value).groups()
        username_r = re.compile('/profiles/(.*)/')
        if username_r.search(path):
            username = username_r.search(path).groups()[0]
            try:
                other_user = User.objects.get(username=username)
            except User.DoesNotExist:
                return value
            if user == other_user:
                ret = re.sub(re.escape(human_name), 'you', value)
                return ret
    return value


@register.simple_tag
def fullname(value):
    try:
        user = User.objects.get(username=value)
        profile = user.get_profile()

        if profile.first_name and profile.last_name:
            return profile.first_name + " " + profile.last_name
        elif user.first_name and user.last_name:
            return user.first_name + " " + user.last_name
        else:
            return value
    except:
        return value


@register.simple_tag
def firstname(value):
    try:
        user = User.objects.get(username=value)
        profile = user.get_profile()
        name = profile.first_name
        if name != '':
            return name.title()
        else:
            name = user.first_name.title()
            if name != '':
                return name
            else:
                return value
    except:
        return value.title()


@register.simple_tag
def lastname(value):
    try:
        user = User.objects.get(username=value)
        profile = user.get_profile()
        name = profile.last_name
        if name != '':
            return name
        else:
            name = user.last_name
            if name != '':
                return name
            else:
                return value
    except:
        return value
