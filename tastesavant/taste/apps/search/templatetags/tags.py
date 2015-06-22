from django import template

register = template.Library()

@register.filter
def truncatechars(s, limit):
    """ Truncate after a certain number of characters. """
    string = []
    count = 0
    for word in s.split():
        if (count + len(word) + len('...')) > limit:
            string.append('...')
            break
        else:
            string.append(word)
            count += len(word) + len(' ')
    return u' '.join(string)

@register.filter
def truncatechars2(s, limit):
    """ Truncate after a certain number of characters. """
    val = s.strip()
    if len(val) < limit:
        return val
    else:
        return val[0:limit] + "..."

def htmlattributes(value, arg):
    """Replace the attribute id for Field 'value' with 'arg'."""
    attrs = value.field.widget.attrs
    data = arg.strip()
    kvs = data.split(',') 
    
    for string in kvs:
        kv = string.split(':')
        attrs[kv[0].replace(' ', '')] = kv[1].strip()
        
    rendered = str(value)
    return rendered

register.filter('htmlattributes', htmlattributes)
