from codecs import BOM_UTF8
from gdata.gauth import AuthSubToken
from gdata.contacts.client import ContactsClient, ContactsQuery
import gdata.contacts.service
from django.core.validators import email_re
import vobject
from taste.apps.invite.models import Contact

def import_vcards(stream, user):
    total = 0
    imported = 0
    for card in vobject.readComponents(stream):
        total += 1
        try:
            name = card.fn.value
            email = card.email.value
            try:
                Contact.objects.get(user=user, email=email)
            except Contact.DoesNotExist:
                Contact(user=user, name=name, email=email).save()
                imported += 1
        except AttributeError:
            pass
    return imported, total

def import_yahoo(address_book, user):
    for contact in address_book['contacts']['contact']:
        name = ''
        email = ''
        fields = contact['fields']
        for f in fields:
            value = f['value']
            if type(value) is dict:
                try:
                    last_name = value.get('familyName', None)
                    first_name = value.get('givenName', None)
                    if last_name or first_name:
                        name = first_name + ' ' + last_name
                        if name != '' and email != '':
                            break
                except:
                    pass
            if type(value) is str or type(value) is unicode:
                if email_re.match(value):
                    email = value
                    if  name != '' and email != '':
                        break
        if email:
            contact, created = Contact.objects.get_or_create(user=user,
                email=email, defaults = {'name': name, 'provider': 'yahoo'})

def import_google(string_token, user):
    token = AuthSubToken(string_token)
    gd_client = ContactsClient(source='chicago.tastesavant.com')
    query = ContactsQuery()
    query.max_results = 5000
    feed = gd_client.GetContacts(auth_token=token, q=query)
    contacts = []
    BOM = unicode(BOM_UTF8, 'utf-8')
    for entry in feed.entry:
        name = entry.title.text
        if name is not None:
            name = name.encode('ascii', 'xmlcharrefreplace').replace(BOM, '')
        for e in entry.email:
            email = e.address.replace(BOM, '')
            try:
                contacts.append(Contact(
                    user=user,
                    email=email,
                    name=name,
                    provider='google'
                    ))
            except:
                pass
    try:
        Contact.objects.bulk_create(contacts)
    except Exception as e:
        pass
