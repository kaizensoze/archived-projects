from django.conf import settings
from django.utils import simplejson as json
from datetime import datetime
import time
import urllib

def _setting(name, default=None):
    return getattr(settings, name, default)

class Socialable(object):
    AUTHORIZATION_URL = None
    CONSUMER_KEY = None
    CONSUMER_SECRET = None
    TOKEN_NAME = 'access_token'

    def set_authorization(self, access_token, client_id=None):
        self.access_token = access_token
        if client_id:
            self.client_id = client_id

    def get(self, path, **kwargs):
        return self.request(path, get=kwargs)

    def post(self, path, **kwargs):
        return self.request(path, post=kwargs)

    def request(self, path, get=None, post=None, **options):
        if not get:
            get = {}
        if self.access_token and options.get('use_auth', True):
            if post is not None:
                post[self.TOKEN_NAME] = self.access_token
            else:
                get[self.TOKEN_NAME] = self.access_token

        post_data = None if post is None else urllib.urlencode(post)

        try:
            response = urllib.urlopen(self.AUTHORIZATION_URL + path + "?" +
                                  urllib.urlencode(get), post_data)
        except IOError as e:  # 400 errors fall under this.
            return {'meta': {
                    'code': e.args[1],
                    'errorType': e.args[0],
                    'errorDetail': e.args[2],
                }
            }

        try:
            data = json.loads(response.read())
            if data.get('error'):
                raise APIException(data['error']['type'],
                                   data['error']['message'])
        finally:
            response.close()
        return data

class APIException(Exception):
    def __init__(self, type, message):
        Exception.__init__(self, message)
        self.type = type

class GraphAPI(Socialable):
    AUTHORIZATION_URL = 'https://graph.facebook.com/'

    def __init__(self, access_token=None, user_id=None):
        self.set_authorization(access_token, user_id)

    def get_connections(self, connection_type, user_id=None, get=None):
        if not user_id:
            user_id = self.client_id

        path = user_id + "/" + connection_type
        return self.request(path, get)

    def get_friends(self):
        res = self.get_connections('friends')
        if res.get('data', None):
            return res['data']

    def get_introspection(self, user_id=None):
        if not user_id:
            user_id = self.client_id
        return self.request(user_id, get={'metadata':1}, use_auth=False)

class Foursquare(Socialable):
    """
    The :class:`Request <socialable.Foursquare>` object. Handles
    serialization of arguments for API calls, automatic deserialization
    of responses returned by API, automatic argument formatting to
    documentation spec.
    """

    AUTHORIZATION_URL = 'https://api.foursquare.com/v2/'
    TOKEN_NAME = 'oauth_token'
    CONSUMER_KEY = _setting('FOURSQUARE_CONSUMER_KEY', None)
    CONSUMER_SECRET = _setting('FOURSQUARE_CONSUMER_SECRET', None)

    def __init__(self, access_token=None, user_id=None):
        self.set_authorization(access_token, user_id)

    @property
    def authentication(self):
        return {'client_id': self.CONSUMER_KEY,
                'client_secret': self.CONSUMER_SECRET}

    def inject_authentication(self, arguments):
        return dict(arguments.items() + self.authentication.items())

    def strfcoordinates(self, latitude, longitude):
        """Convert a given latitude longitude pair into a string formatted
        to the API specs. (http://bit.ly/foursquare-venue-api-params)
        """
        return "%.5f,%.5f" % (latitude, longitude)

    def to_epoch(self, timestamp):
        """Converts datetime tulip into its seconds since Epoch representation.
        Returns :type:`unicode <type 'unicode'>` object.

        :param timestamp: an instance of a datetime tuple
        """
        if isinstance(timestamp, datetime):
            return unicode(int(time.mktime(timestamp.timetuple())))
        else:
            return unicode(timestamp)

    @property
    def get_epoch_now(self):
        """Current time represented in seconds since the Epoch.
        Returns :type:`unicode <type 'unicode'>` object."""
        return self.to_epoch(datetime.now())

    def get_checkins(self, user_id=None, limit=250, offset=0,
                     after_timestamp=None, before_timestamp=None,
                     values=None):
        """Get the history of check-ins for an authenticated user.
        Returns :type:`dict <type 'dict'>` object.

        :param user_id: (optional) String identity of a authorized user.
        :param limit: (optional) Number of results to return, up to 250.
        :param offset: (optional) The number of results to skip (pagination).
        :param after_timestamp: (optional) Retrieve the first results to
               follow these seconds since epoch.
        :param before_timestamp: (optional) Retrieve the first results
               prior to these seconds since epoch.
        :param values: (optional) A list defining the `values` displayed
               for each item in the resultset.
        """

        #If `user_id` is not passed as an argument, assume it was previously
        # declared.
        if not user_id:
            user_id = self.client_id

        arguments = {}
        if limit:
            arguments['limit'] = limit
        if offset:
            arguments['offset'] = offset
        if after_timestamp:
            arguments['afterTimestamp'] = self.to_epoch(after_timestamp)
        if before_timestamp:
            arguments['beforeTimestamp'] = self.to_epoch(before_timestamp)

        path = 'users/' + user_id + '/checkins'
        results = self.get(path, **arguments)
        results = results['checkins']['items']
        if values is None:
            return results
        else:
            return self.filter_values(values, results)

    def filter_values(self, values, results):
        values_set = []

        if len(values) > 1:
            for result in results:
                result_set = {}
                for field in values:
                    if field in result.keys():
                        result_set[field] = result[field]
                values_set.append(result_set)
        else:
            for result in results:
                for field in values:
                    if field in result.keys():
                        values_set.append(result[field])
        return values_set

    def get(self, path, oauth_consumer=False, **kwargs):
        """Shortcut to HTTP `GET` request when making API calls.
        Returns :type:`dict <type 'dict'>` object.

        :param path: Additional path from base URI to desired resource.
        :param oauth_consumer: (optional) Boolean to optionally pass
               OAuth consumer key and token along with GET request.
        """

        if oauth_consumer:
            kwargs = self.inject_authentication(kwargs)
        if 'v' not in kwargs:
            kwargs['v'] = '20130227'  # API compat date
        response = super(Foursquare, self).get(path, **kwargs)
        return self.callback(response)

    def callback(self, response):
        if 400 <= response['meta']['code'] < 500:
            error_type = response['meta']['errorType']
            message = response['meta']['errorDetail']

            if error_type == 'param_error':
                raise ValueError(message)
            else:
                raise APIException(error_type, message)
        else:
            return response['response']

    def get_venue(self, venue_id):
        path = 'venues/' + venue_id
        response = self.get(path, **self.authentication)
        return response['venue']

    def search_venue(self, latitude, longitude, geo_accuracy=None,
                     altitude=None, alt_accuracy=None, query=None,
                     limit=50, intent=None, categoryId=None, url=None,
                     providerId=None, linkedId=None):
        """Returns a list of venues near the current location, optionally
        matching the search term.
        Returns :type:`dict <type 'dict'>` object.

        :param latitude: Decimal representation of venue's latitude.
        :param longitude: Decimal representation of venue's longitude.
        :param geo_accuracy: (optional) Accuracy of lat/long, in meters.
        :param altitude: (optional) Altitude of the user's location, in meters.
        :param alt_accuracy: (optional) Accuracy of the user's altitude, in meters.
        :param query: (optional) A search term to be applied against tips, category,
               tips, etc. at a venue.
        :param limit: (optional) Number of results to return, up to 50.
        :param intent: (optional) One of the values below, indicating your
               intent in performing the search. If no value is specified,
               defaults to `checkin`.
        :param categoryId: (optional) A category to limit results to. Does not
               work in conjunction with intent.
        :param url: (optional) A third-party URL which we will attempt to
               match against our map of venues to URLs.
        :param providerId: (optional) Identifier for a known third party
               that is part of our map of venues to URLs, used in
               conjunction with linkedId.
        :param linkedId: (optional) Identifier used by third party specifed in
               providerId, which we will attempt to match against our map of
               venues to URLs.
        """
        path = '/venues/search'
        arguments = {}

    def explore_venue(self, latitude, longitude, geo_accuracy=None,
                     altitude=None, alt_accuracy=None, radius=None,
                     section=None, query=None, limit=50, intent=None,
                     novelty=None):
        """Returns a list of recommended venues near the current location.
        Returns :type:`dict <type 'dict'>` object.

        :param latitude: Decimal representation of venue's latitude.
        :param longitude: Decimal representation of venue's longitude.
        :param geo_accuracy: (optional) Accuracy of lat/long, in meters.
        :param altitude: (optional) Altitude of the user's location, in meters.
        :param alt_accuracy: (optional) Accuracy of the user's altitude, in meters.
        :param radius: (optional) Radius to search within, in meters.
        :param section: (optional) One of food, drinks, coffee, shops, arts,
               or outdoors. Choosing one of these limits results to venues
               with categories matching these terms.
        :param query: (optional) A search term to be applied against tips, category,
               tips, etc. at a venue.
        :param limit: (optional) Number of results to return, up to 50.
        :param intent: (optional) Limit results to venues with specials.
        :param novelty: (optional) Pass new or old to limit results to places
               the acting user hasn't been or has been, respectively. Omitting
               this parameter returns a mixture.
        """

        path = '/venues/explore'
        arguments = {}

        if latitude and longitude:
            arguments['ll'] = self.strfcoordinates(latitude, longitude)
        if geo_accuracy:
            arguments['llAcc'] = geo_accuracy
        if altitude:
            arguments['alt'] = altitude
        if alt_accuracy:
            arguments['altAcc'] = alt_accuracy
        if radius:
            arguments['radius'] = radius
        if section:
            arguments['section'] = section
        if query:
            arguments['query'] = query
        if limit:
            arguments['limit'] = limit
        if intent:
            arguments['intent'] = intent
        if novelty:
            arguments['novelty'] = novelty

        results = self.get(path, oauth_consumer=True, **arguments)
        results = results['groups'][0]['items']

        if len(results) == 1:
            return results[0]['venue']
