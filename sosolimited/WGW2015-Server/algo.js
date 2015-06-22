
var assert = require('assert');
var restify = require('restify');
var redis = require('redis').createClient();
var moment = require('moment');
var momentRange = require('moment-range');
var util = require('util');
var stateData = require('./states.json');
var streamData = require('./streams.json');
var _ = require('lodash');

redis.on("error", function (err) {
  console.log(err);
});

var client = restify.createJsonClient({
  url: 'http://api.massrelevance.com',
  version: '~1.0'
});

var utcOffsetString = '-0700';  // Mountain Time Zone
var closedPollWindowStartTime = adjustedDate(moment().zone(utcOffsetString).hour(18).minute(50)); // 06:50PM MT
var closedPollWindowEndTime = adjustedDate(moment().zone(utcOffsetString).hour(18).minute(59));   // 06:59PM MT
var closedPollWindow = moment().range(closedPollWindowStartTime, closedPollWindowEndTime);

var metaPollInterval = 30 * 1000;
var streamPollInterval = 3 * 1000;

var currentHourCounts = {};
var lastUnavailableTimes = {};

sortStreams();
setupRedisData();
startPolling();

function sortStreams() {
  streamData.streams.sort(function(a, b) {
    if (a.name < b.name) return -1
    if (a.name > b.name) return 1;
    return 0;
  });
}

// setup redis data
function setupRedisData() {
  // streams
  for (var streamIdx in streamData.streams) {
    var stream = streamData.streams[streamIdx];

    var streamKey =  util.format('streams:%s', stream.name);
    redis.hmset(streamKey, stream);
    redis.zadd('streams', streamIdx, streamKey);
  }

  // direct vote sources
  var sources = ['microsite-pick', 'microsite-zip', 'vph', ''];
  for (var sourceIdx in sources) {
    var source = sources[sourceIdx];
    redis.zadd('sources', sourceIdx, source);
  }
}

function startPolling() {
  for (var streamIdx in streamData.streams) {
    var stream = streamData.streams[streamIdx];

    // initialize current hour counts
    currentHourCounts[stream.name] = {};

    // poll stream meta api
    pollStreamMetaData(stream, true);

    // poll stream api
    pollStreamData(stream);
  }
}

function pollStreamMetaData(stream, init) {
  var streamURL = util.format('/%s/%s/meta.json?num_days=1&num_hours=24&num_minutes=120', streamData.account, stream.name);
  // console.log(client.url.href + streamURL);

  if (moment().minute() < 1) {
    currentHourCounts[stream.name] = 0;
  }

  client.get(streamURL, function (err, req, res, meta) {
    // error handling
    if (err) {
      // if service is unavailable (503) for more than 15 seconds let script crash to trigger monit
      if (!res || res.statusCode === 503) {
        if (typeof lastUnavailableTimes['streamMeta'] === 'undefined') {
          lastUnavailableTimes['streamMeta'] = new Date().getTime();
        }
        if (new Date().getTime() - lastUnavailableTimes['streamMeta'] > 15 * 1000) {
          assert.ifError(err);
        }
      } else {
        // if not the expected service unavailable case, report whatever happened
        assert.ifError(err);
      }
    } else {
      lastUnavailableTimes['streamMeta'] = undefined;
    }

    updateCount(stream, meta, init);

    setTimeout(function() {
      pollStreamMetaData(stream);
    }, metaPollInterval);
  });
}

function pollStreamData(stream) {
  // retrieve last entity id
  var lastEntityIdKey = util.format('stream:%s:lastEntityId', stream.name);
  redis.get(lastEntityIdKey, function(err, reply) {
    var lastEntityId;
    if (reply !== null) {
      lastEntityId = reply.toString();
    }

    var sinceId = lastEntityId ? util.format('&since_id=%s', lastEntityId) : '';

    var streamURL = util.format('/%s/%s.json?geo_hint=1&limit=200&reverse=1%s', streamData.account, stream.name, sinceId);
    // console.log(client.url.href + streamURL);

    client.get(streamURL, function (err, req, res, tweets) {
      // error handling
      if (err) {
        // if service is unavailable (503) for more than 15 seconds let script crash to trigger monit
        if (!res || res.statusCode === 503) {
          if (typeof lastUnavailableTimes['streamMeta'] === 'undefined') {
            lastUnavailableTimes['streamMeta'] = new Date().getTime();
          }
          if (new Date().getTime() - lastUnavailableTimes['streamMeta'] > 15 * 1000) {
            assert.ifError(err);
          }
        } else {
          // if not the expected service unavailable case, report whatever happened
          assert.ifError(err);
        }
      } else {
        lastUnavailableTimes['streamMeta'] = undefined;
      }

      for (var tweetIndex in tweets) {
        var tweet = tweets[tweetIndex];

        if (tweet.geo_hint) {
          if (tweet.geo_hint.country === 'US') {
            var stateAbbr = tweet.geo_hint.state;
            incrementStateCount(stream, stateAbbr);
          }
        } else if (tweet.place) {
          if (tweet.place.country_code === 'US') {
            var stateAbbr = tweet.place.full_name.split(', ')[1];
            incrementStateCount(stream, stateAbbr);
          }
        }

        // increment current hour count if entity was created in current hour
        var entityCreatedAt = tweet.created_at;
        var entityCreatedAtMomentObj = moment(entityCreatedAt, "ddd MMM DD HH:mm:ss ZZ YYYY");
        var startOfHour = moment().startOf('hour');
        if (entityCreatedAtMomentObj.isSame(startOfHour) || entityCreatedAtMomentObj.isAfter(startOfHour)) {
          currentHourCounts[stream.name]++;

          // increment hour and day count
          var date = adjustedDate(moment());
          var dateString = date.format("YYYY-MM-DD");

          var dayKey = util.format('stream:%s:countType:counts:day:%s', stream.name, dateString);
          redis.hincrby(dayKey, "count", 1);

          var hourKey = util.format('stream:%s:countType:counts:day:%s:hour:%s', stream.name, dateString, date.hour());
          redis.hincrby(hourKey, "count", 1);
        }

        // record last entity id for given stream
        redis.set(lastEntityIdKey, tweet.entity_id);
      }

      fillInMissingStates(stream);

      setTimeout(function() {
        pollStreamData(stream);
      }, streamPollInterval);
    });
  });
}

function updateCount(stream, meta, init) {
  if (moment().seconds() <= 29 && !init) {
    return;
  }

  var date = adjustedDate(moment());
  var dateString = date.format("YYYY-MM-DD");

  var hours = meta.activity.hourly.approved;
  var minutes = meta.activity.minute.approved;

  // official past hour count
  var pastHourCount = hours[hours.length - 1];

  // past hour count calculated from minutes
  var currentMinute = moment().minute();
  var numMinutesIntoCurrentHour = currentMinute; // massrel is always behind by a minute so don't add 1
  var pastHourStartIndex = -60 - numMinutesIntoCurrentHour;
  var pastHourEndIndex = -(numMinutesIntoCurrentHour);
  if (pastHourEndIndex === 0) {
    pastHourEndIndex = undefined; // this will go up to and include the last item in the minutes array
  }
  var minutesInPastHour = minutes.slice(pastHourStartIndex, pastHourEndIndex);
  var calculatedPastHourCount;
  try {
    calculatedPastHourCount= minutesInPastHour.reduce(function(a, b) {
      return a + b;
    });
  } catch (e) {
    calculatedPastHourCount = 0;
  }

  if (pastHourCount === calculatedPastHourCount) {
    // current hour count
    var hourCount;
    var minutesInCurHour = minutes.slice(pastHourEndIndex);
    if (minutesInCurHour.length > 60) {
      minutesInCurHour = [];
    }
    try {
      hourCount = minutesInCurHour.reduce(function(a, b) {
        return a + b;
      });
    } catch (e) {
      hourCount = 0;
    }

    currentHourCounts[stream.name] = hourCount;

    // day count [ = past hours + current hour]
    var dayCount = 0;
    if (date.hour() === 0) { // edge case since array.slice(0) returns entire array
    } else {
      var hourCountsForCurrentDay = meta.activity.hourly.approved.slice(-1 * date.hour());
      dayCount = hourCountsForCurrentDay.reduce(function(a, b) {
        return a + b;
      });
    }
    dayCount += hourCount;

    var dayIndex = parseInt(date.format("YYYYMMDD"));
    var hourIndex = date.hour();

    var daysKey = util.format('stream:%s:countType:counts:days', stream.name);
    var dayKey = util.format('stream:%s:countType:counts:day:%s', stream.name, dateString);

    var hoursKey = util.format('stream:%s:countType:counts:day:%s:hours', stream.name, dateString);
    var hourKey = util.format('stream:%s:countType:counts:day:%s:hour:%s', stream.name, dateString, date.hour());

    // add day to set of days
    redis.zadd(daysKey, dayIndex, dayKey);

    // add hour to set of hours
    redis.zadd(hoursKey, hourIndex, hourKey);

    // update the counts (if polls are open)
    if (!date.within(closedPollWindow)) {
      // set day count [if higher than current]
      redis.hget(dayKey, 'count', function(err, obj) {
        redis.hmset(dayKey, { 'streamName': stream.name, 'day': dateString });
        if (!obj || dayCount >= parseInt(obj)) {
          redis.hset(dayKey, 'count', dayCount);
        }
      });
      
      // set hour count [if higher than current]
      redis.hget(hourKey, 'count', function(err, obj) {
        redis.hmset(hourKey, { 'streamName': stream.name, 'day': dateString, 'hour': date.hour() });
        if (!obj || hourCount >= parseInt(obj)) {
          redis.hset(hourKey, 'count', hourCount);
        }
      });
    }

    // sync past hour
    if (moment().minutes() < 3) {
      syncPastHourCount(stream, date, pastHourCount);
    }
  }
}

function syncPastHourCount(stream, dateParam, pastHourCount) {
  // console.log('sync past hour to:', pastHourCount);

  var date = dateParam.clone().subtract(1, 'hour');
  var dateString = date.format("YYYY-MM-DD");

  // get the count we have for past hour
  var hourKey = util.format('stream:%s:countType:counts:day:%s:hour:%s', stream.name, dateString, date.hour());
  redis.hget(hourKey, 'count', function(err, oldHourCount) {
    var massRelPastHourCount = pastHourCount;
    var ourPastHourCount = parseInt(oldHourCount || 0);

    // update our past hour count
    redis.hmset(hourKey, { 'streamName': stream.name, 'day': dateString, 'hour': date.hour(), 'count': massRelPastHourCount });
    
    // update day count
    var dayKey = util.format('stream:%s:countType:counts:day:%s', stream.name, dateString);
    redis.hincrby(dayKey, "count", (massRelPastHourCount - ourPastHourCount));
  });
}

function incrementStateCount(stream, stateAbbr) {
  var date = adjustedDate(moment());
  var dateString = date.format("YYYY-MM-DD");

  var stateObj = stateData.map[stateAbbr];
  if (typeof stateObj === 'undefined') {
    return;
  }

  var dayIndex = parseInt(date.format("YYYYMMDD"));
  var hourIndex = date.hour();
  var stateIndex = stateData.abbreviations.indexOf(stateAbbr);

  /*
    stream:packers-game:countType:stateCounts:days
      stream:packers-game:countType:stateCounts:day:2014-12-05

    stream:packers-game:countType:stateCounts:day:2014-12-05:states
      stream:packers-game:countType:stateCounts:day:2014-12-05:state:NY

    stream:packers-game:countType:stateCounts:day:2014-12-05:hours
      stream:packers-game:countType:stateCounts:day:2014-12-05:hour:23

    stream:packers-game:countType:stateCounts:day:2014-12-05:hour:23:states
      stream:packers-game:countType:stateCounts:day:2014-12-05:hour:23:state:NY
   */

  var daysKey = util.format('stream:%s:countType:stateCounts:days', stream.name);
  var dayKey = util.format('stream:%s:countType:stateCounts:day:%s', stream.name, dateString);

  var dayStatesKey = util.format('stream:%s:countType:stateCounts:day:%s:states', stream.name, dateString);
  var dayStateKey = util.format('stream:%s:countType:stateCounts:day:%s:state:%s', stream.name, dateString, stateAbbr);

  var hoursKey = util.format('stream:%s:countType:stateCounts:day:%s:hours', stream.name, dateString);
  var hourKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s', stream.name, dateString, date.hour());

  var hourStatesKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s:states', stream.name, dateString, date.hour());
  var hourStateKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s:state:%s', stream.name, dateString, date.hour(), stateAbbr);

  // add day to set of days
  redis.zadd(daysKey, dayIndex, dayKey);
  redis.hmset(dayKey, { 'streamName': stream.name, 'day': dateString }); // set day object
  
  // add day state to set of day states
  redis.zadd(dayStatesKey, stateIndex, dayStateKey);

  // add hour to set of hours
  redis.zadd(hoursKey, hourIndex, hourKey);
  redis.hmset(hourKey, { 'streamName': stream.name, 'day': dateString, 'hour': date.hour() }); // set hour object
  
  // add hour state to set of hour states
  redis.zadd(hourStatesKey, stateIndex, hourStateKey);

  // set day state object
  var dayStateObj = clone(stateObj);
  dayStateObj.streamName = stream.name;
  dayStateObj.day = dateString;
  redis.hmset(dayStateKey, dayStateObj);

  // set hour state object
  var hourStateObj = clone(dayStateObj);
  hourStateObj.hour = date.hour();
  redis.hmset(hourStateKey, hourStateObj);

  // increment day state, hour state counts (if polls are open)
  if (!date.within(closedPollWindow)) {
    redis.hincrby(dayStateKey, "count", 1);
    redis.hincrby(hourStateKey, "count", 1);
  }
}

function fillInMissingStates(stream) {
  var date = adjustedDate(moment());
  var dateString = date.format("YYYY-MM-DD");

  var dayIndex = parseInt(date.format("YYYYMMDD"));
  var hourIndex = date.hour();

  // fill in missing states for current day
  var dayStatesKey = util.format('stream:%s:countType:stateCounts:day:%s:states', stream.name, dateString);
  redis.zrange(dayStatesKey, 0, -1, function(err, dayStateKeys) {
    var allStates = stateData.abbreviations;

    var statesWeHave = _.map(dayStateKeys, function(dayStateKey) {
      return dayStateKey.split(':').slice(-1)[0];
    });

    var missingStates = _.difference(allStates, statesWeHave);

    for (var i=0; i < missingStates.length; i++) {
      var missingStateAbbr = missingStates[i];

      // add day state
      var stateIndex = stateData.abbreviations.indexOf(missingStateAbbr);
      var dayStateKey = util.format('stream:%s:countType:stateCounts:day:%s:state:%s', stream.name, dateString, missingStateAbbr);
      redis.zadd(dayStatesKey, stateIndex, dayStateKey);

      // set day state object
      var missingStateObj = clone(stateData.map[missingStateAbbr]);
      missingStateObj.streamName = stream.name;
      missingStateObj.day = dateString;
      missingStateObj.count = 0;
      redis.hmset(dayStateKey, missingStateObj);
    }
  });

  // fill in missing states for current hour
  var hourStatesKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s:states', stream.name, dateString, date.hour());
  redis.zrange(hourStatesKey, 0, -1, function(err, hourStateKeys) {
    var allStates = stateData.abbreviations;

    var statesWeHave = _.map(hourStateKeys, function(hourStateKey) {
      return hourStateKey.split(':').slice(-1)[0];
    });

    var missingStates = _.difference(allStates, statesWeHave);

    for (var i=0; i < missingStates.length; i++) {
      var missingStateAbbr = missingStates[i];

      // add hour state
      var stateIndex = stateData.abbreviations.indexOf(missingStateAbbr);
      var hourStateKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s:state:%s', stream.name, dateString, date.hour(), missingStateAbbr);
      redis.zadd(hourStatesKey, stateIndex, hourStateKey);

      // set day state object
      var missingStateObj = clone(stateData.map[missingStateAbbr]);
      missingStateObj.streamName = stream.name;
      missingStateObj.day = dateString;
      missingStateObj.hour = date.hour();
      missingStateObj.count = 0;
      redis.hmset(hourStateKey, missingStateObj);
    }
  });
}

// convert date so that 7PM current day is 0 hour of next day
function adjustedDate(momentDate) {
  return momentDate.zone(utcOffsetString).add(5, 'hour');
}

function clone(obj) {
  return JSON.parse(JSON.stringify(obj));
}
