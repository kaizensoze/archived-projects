
var Promise = require("bluebird");
var moment = require('moment');
var redis = require('redis');
var util = require('util');
var stateData = require('./states.json');

var client = redis.createClient();

// Promise.promisifyAll(redis);

var utcOffsetString = '-0700';  // Mountain Time Zone

function adjustedDate(momentDate) {
  return momentDate.zone(utcOffsetString).add(5, 'hour');
}

function clone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

// The issue to address is that if there are no votes for a state in a given period of time (e.g. hour),
// a redis key will be missing for that state and hour and the state won't be returned in the json.
// This runs in a crontab at the start of every hour and initializes the count to 0 [if a count value
// doesn't already exist].

client.zrange('streams', 0, -1, function(err, streamKeys) {
  for (var i=0; i < streamKeys.length; i++) {
    var streamKey = streamKeys[i];
    client.hgetall(streamKey, function(err, stream) {
      var currentDay = adjustedDate(moment());
      var currentDayString = currentDay.format("YYYY-MM-DD");

      // day
      var currentDayKey = util.format('stream:%s:countType:stateCounts:day:%s', stream.name, currentDayString);
      var currentDayIndex = parseInt(currentDay.format("YYYYMMDD"));
      var daysKey = util.format('stream:%s:countType:stateCounts:days', stream.name);

      client.zadd(daysKey, currentDayIndex, currentDayKey);
      client.hmset(currentDayKey, { 'streamName': stream.name, 'day': currentDayString });

      // hour
      var hourIndex = currentDay.hour();
      var currentHourKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s', stream.name, currentDayString, currentDay.hour());
      var hoursKey = util.format('stream:%s:countType:stateCounts:day:%s:hours', stream.name, currentDayString);

      client.zadd(hoursKey, hourIndex, currentHourKey);
      client.hmset(currentHourKey, { 'streamName': stream.name, 'day': currentDayString, 'hour': currentDay.hour() });

      // states
      for (var i=0; i < stateData.abbreviations.length; i++) {
        var stateAbbr = stateData.abbreviations[i];
        var state = stateData.map[stateAbbr];
        var stateIndex = stateData.abbreviations.indexOf(stateAbbr);

        // day state
        var dayStateKey = util.format('stream:%s:countType:stateCounts:day:%s:state:%s', stream.name, currentDayString, stateAbbr);
        var dayStatesKey = util.format('stream:%s:countType:stateCounts:day:%s:states', stream.name, currentDayString);

        // console.log(dayStateKey);

        var dayStateObj = clone(state);
        dayStateObj.streamName = stream.name;
        dayStateObj.day = currentDayString;

        client.zadd(dayStatesKey, stateIndex, dayStateKey);

        (function(stateAbbr, dayStateKey, dayStateObj) {
          client.hgetall(dayStateKey, function(err, obj) {
            if (!obj || !obj.count) {
              dayStateObj.count = 0;
            }
            client.hmset(dayStateKey, dayStateObj);

            // hour state
            var hourStateKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s:state:%s', stream.name, currentDayString, currentDay.hour(), stateAbbr);
            var hourStatesKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s:states', stream.name, currentDayString, currentDay.hour());

            // console.log(hourStateKey);

            var hourStateObj = clone(dayStateObj);
            hourStateObj.hour = currentDay.hour();

            client.zadd(hourStatesKey, stateIndex, hourStateKey);

            client.hgetall(hourStateKey, function(err, obj2) {
              if (!obj2 || !obj2.count) {
                hourStateObj.count = 0;
              }
              client.hmset(hourStateKey, hourStateObj);

              // check if we're good to exit
              var streamKey = 'streams:'+dayStateObj.streamName;
              var streamKeyIndex = streamKeys.indexOf(streamKey);
              if (streamKeyIndex === streamKeys.length - 1) {
                var stateIndex = stateData.abbreviations.indexOf(stateAbbr);
                if (stateIndex === stateData.abbreviations.length - 1) {
                  process.exit();
                }
              }
            });
          });
        })(stateAbbr, dayStateKey, dayStateObj);
      }
    });
  }
});


