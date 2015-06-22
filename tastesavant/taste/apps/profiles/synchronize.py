from datetime import datetime
from django.utils import simplejson as json
from django.conf import settings

import requests

# @note: Shouldn't this be a new-style class? --kit
class FourSquare:
    @property
    def base_url(self):
        return 'https://api.foursquare.com/v2'

    def get(self, url, *args, **kwargs):
        if 'params' not in kwargs:
            kwargs['params'] = {}
        if 'v' not in kwargs['params']:
            kwargs['params']['v'] = '20130227'  # API compat date
        return requests.get(url, *args, **kwargs)

    def get_venue(self, venue_id):
        path = "/venues/%s" % venue_id
        return self.venue_api(path)

    def search_venue(self, latitude, longitude, query=None, **extra_args):
        url_path = '/venues/explore'
        latlng = self._format_lat_lng(latitude, longitude)
        results = self.venue_api(url_path, ll=latlng, query=query,
                                 **extra_args)
        results = results['response']['groups'][0]['items']
        if len(results) == 1:
            return results[0]['venue']

    def _format_lat_lng(self, latitude, longitude):
        return "%.5f,%.5f" % (latitude, longitude)

    def venue_api(self, path="/venues", **kwargs):
        url = self.base_url + path
        args = {}
        args['client_id'] = getattr(settings, 'FOURSQUARE_CONSUMER_KEY', None)
        args['client_secret'] = getattr(settings,
                                        'FOURSQUARE_CONSUMER_SECRET', None)

        for key in kwargs:
            args[key]=kwargs[key]

        response = self.get(url, params=args)
        if response.ok:
            return json.loads(response.content)

    def epoch_seconds(self,date):
        """Returns the number of seconds from the epoch to date."""

        epoch = datetime(1970, 1, 1)
        td = date - epoch
        return int(td.days * 86400 + td.seconds + (float(td.microseconds) / 1000000))

    def get_checkins(self, uid, access_token):
        checkins = self.user_api(uid, access_token)
        checkins = checkins['response']['checkins']['items']
        return checkins

    def get_venue_id(self, checkins):
        if checkins:
            return [(v['venue']['id'],
                     datetime.fromtimestamp(v['createdAt'])) for v in checkins]

    def user_api(self, uid, access_token, last_sync=None):
        url = self.base_url + '/users/%s/checkins' % uid
        args={}

        if last_sync:
            last_sync = self.epoch_seconds(last_sync)
            args['afterTimestamp'] = last_sync
        args['oauth_token'] = access_token

        response = self.get(url, params=args)
        if response.ok:
            return json.loads(response.content)
