
var request = require('superagent');
var util = require('util');

(function(window) {
  'use strict';
  
  var sosowgw = (function() {
    // account
    var account = 'sosowgw';

    var wgwapiServer = 'http://wgwapi.com'; // 'http://localhost:3000'

    var streams;

    var intervals = [];

    var maxGeoEvents = 50;

    var pollInterval = 5 * 1000;
    var lastEntityId = {};
    var lastPageReloadTime = new Date().getTime();

    var excludeDirectVotes;
    var numDays;

    // data objects
    var counts = {};
    var geoEvents = [];
    var stateCounts = {};

    // initialize streams and pollers
    function init() {
      pollCounts();
      intervals.push(setInterval(pollCounts, pollInterval));

      pollStateCounts();
      // intervals.push(setInterval(pollStateCounts, pollInterval));

      request.get(wgwapiServer + '/streams', function(res) {
        streams = JSON.parse(res.text);
        for (var i=0; i < streams.length; i++) {
          var stream = streams[i];
          pollStreamData(stream);
          intervals.push(setInterval(pollStreamData, pollInterval, stream));
        }
      });
    }
    init();

    function pollCounts() {
      request.get(wgwapiServer + '/counts' + getCountParams(), function(res) {
        counts = JSON.parse(res.text);
      });
    }

    function getCountParams() {
      var params = '';
      if (excludeDirectVotes == true) {
        params += '&excludeDirectVotes=1';
      }
      if (typeof numDays !== 'undefined') {
        params += util.format('&numDays=%s', numDays);
      }

      if (params.length > 0) {
        params = params.replace('&', '?');
      }

      return params;
    }

    function pollStateCounts() {
      request.get(wgwapiServer + '/stateCounts', function(res) {
        stateCounts = JSON.parse(res.text);
      });
    }

    function pollStreamData(stream) {
      var sinceId = lastEntityId[stream.name] ? util.format('&since_id=%s', lastEntityId[stream.name]) : '';
      var streamURL = util.format('http://api.massrelevance.com/%s/%s.json?geo_hint=1&limit=50%s', account, stream.name, sinceId);

      request.get(streamURL, function(res) {
        var entities = JSON.parse(res.text);
        for (var entityIndex in entities) {
          var entity = entities[entityIndex];

          // // if tweet was created prior to last page reload time, ignore [since we only care about real-time geo events relative to page loading]
          // var tweetCreatedTime;
          // if (new Date(entity.created_at)) {
          //   tweetCreatedTime = new Date(entity.created_at).getTime();
          // }
          // if (isNaN(tweetCreatedTime) || (tweetCreatedTime && !isNaN(tweetCreatedTime) && tweetCreatedTime < lastPageReloadTime)) {
          //   continue;
          // }

          // check for geo
          var location;
          if (entity.geo_hint && entity.geo_hint.country === 'US') {
            if (entity.geo_hint.coordinates) {
              location = entity.geo_hint.coordinates;
            } else if (entity.geo) {
              location = entity.geo.coordinates;
            } else if (entity.coordinates) {
              location = entity.coordinates.coordinates;
            }
          } else if (entity.place && entity.place.country_code === 'US') {
            if (entity.geo) {
              location = entity.geo.coordinates;
            } else if (entity.coordinates) {
              location = entity.coordinates.coordinates;
            }
          }

          // add geo event
          if (location) {
            var geoEvent = {
              'team': stream.team,
              'username': entity.user.screen_name,
              'name': entity.user.name,
              'location': location,
              'time': entity.created_at,
              'text': entity.text,
            };
            geoEvents.unshift(geoEvent);
          }

          // first entity is the most recent
          if (entityIndex === '0') {
            lastEntityId[stream.name] = entity.entity_id;
          }
        }
      });
    }

    function getCounts() {
      return counts;
    }

    function getStateCounts() {
      return stateCounts;
    }

    function getGeoEvents() {
      var _geoEvents = geoEvents;

      // sort geo events from least to most recent
      _geoEvents.sort(function(a, b) {
        if (new Date(a.time) < new Date(b.time))
          return -1;
        if (new Date(a.time) > new Date(b.time))
          return 1;
        return 0;
      });
      _geoEvents = _geoEvents.slice(-1 * maxGeoEvents);

      geoEvents = [];
      return _geoEvents;
    }

    function postVote(vote) {
      request.post(wgwapiServer + '/postVote', vote, function(error, res) {
      });
    }

    function excludeDirectVotes(exclude) {
      excludeDirectVotes = exclude;
    }

    function setNumDays(_numDays) {
      numDays = _numDays;
    }

    function useDev(flag) {
      if (flag === true) {
        wgwapiServer = 'http://104.237.128.23'; // dev
      } else {
        wgwapiServer = 'http://wgwapi.com';
      }

      // clear out any existing intervals
      for (var i=0; i < intervals.length; i++) {
        clearInterval(intervals[i]);
      }
      intervals = [];

      // re-initialize with updated base url
      init();
    }

    function clone(obj) {
      return JSON.parse(JSON.stringify(obj));
    }

    return {
      'getCounts': getCounts,
      'getStateCounts': getStateCounts,
      'getGeoEvents': getGeoEvents,
      'postVote': postVote,
      'excludeDirectVotes': excludeDirectVotes,
      'setNumDays': setNumDays,
      'useDev': useDev,
    }
  })();

  if (typeof(window.sosowgw) === 'undefined') {
    window.sosowgw = sosowgw;
  }
})(window);
