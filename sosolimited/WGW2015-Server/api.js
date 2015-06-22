
var Promise = require("bluebird");
var moment = require('moment');
var restify = require('restify');
var redis = require('redis');
var util = require('util');
var streamData = require('./streams.json');
var os = require('os');
var _ = require('lodash');

var client = redis.createClient();
var clientAlgo;

// if this is running on a wgw-prod-api machine, connect to wgw-prod-algo
if (os.hostname().match(/wgw-prod-api/g)) {
  clientAlgo = redis.createClient(6379, '192.168.186.201');
} else {
  clientAlgo = redis.createClient();
}

Promise.promisifyAll(redis);

client.on("error", function (err) {
  console.log('client', err);
});
clientAlgo.on("error", function (err) {
  console.log('clientAlgo', err);
});

var server = restify.createServer({
  name: 'sosowgw',
  version: '1.0.0'
});
server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.bodyParser());
server.use(restify.CORS());
server.use(restify.fullResponse());


// util methods
var utcOffsetString = '-0700';  // Mountain Time Zone

function adjustedDate(momentDate) {
  return momentDate.zone(utcOffsetString).add(5, 'hour');
}

function clone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

function filterStreams(json) {
  for (var streamName in json) {
    if (streamName !== 'seahawks-vast') {
      delete json[streamName];
    }
  }
}

function countsJSON(params) {
  // ensure team, date, hour params are arrays
  if (params.team && params.team.constructor !== Array) {
    params.team = [params.team];
  }
  if (params.date && params.date.constructor !== Array) {
    params.date = [params.date];
  }
  if (params.hour && params.hour.constructor !== Array) {
    params.hour = [params.hour];
  }

  if (!params.numDays) {
    params.numDays = 7;
  }

  return new Promise(function(resolve) {
    var todayString = adjustedDate(moment()).format("YYYY-MM-DD");

    var json = {};

    var numDays = {};

    // check if direct votes should be excluded
    var excludeDirectVotes = false;
    if (params.excludeDirectVotes && params.excludeDirectVotes === '1') {
      excludeDirectVotes = true;
    }

    client.zrevrangeAsync('streams', 0, -1).map(function(streamKey) {
      return client.hgetallAsync(streamKey);
    }).map(function(stream) {
      // only get requested teams
      if (params.team && params.team.indexOf(stream.team) === -1) {
        return;
      }

      json[stream.name] = {
        'team': stream.team,
        'days': [],
        'hours': []
      }

      numDays[stream.name] = 0;

      var daysKey = util.format('stream:%s:countType:counts:days', stream.name);
      return client.zrevrangeAsync(daysKey, 0, -1).map(function(dayKey) {
        return client.hgetallAsync(dayKey);
      }).map(function(dayObj) {
        // only get requested days
        if (params.date && params.date.indexOf(dayObj.day) === -1) {
          return;
        }

        // only get up to param.numDays
        if (numDays[stream.name] >= params.numDays) {
          return;
        }

        // remove stream name from day object
        delete dayObj.streamName;

        numDays[stream.name]++;

        // add direct votes to day count
        return client.zrangeAsync('sources', 0, -1).map(function(source) {
          var sourceString = '';
          if (source.length > 0) {
            sourceString = '-' + source;
          }
          var directVotesDayKey = util.format('team:%s:countType:directVotes%s:day:%s', stream.team, sourceString, dayObj.day);
          return client.hgetAsync(directVotesDayKey, 'count').then(function(obj) {
            var directVoteCount = 0;
            if (obj) {
              directVoteCount = parseInt(obj);
            }
            if (!excludeDirectVotes) {
              dayObj.count = (parseInt(dayObj.count) + directVoteCount).toString();
            }
          });
        }).then(function() {
          json[stream.name].days.unshift(dayObj);

          // 3 conditions under which we skip hours
          // 1) day array provided and day isn't requested
          // 2) no day array provided and day isn't current day
          // 3) noHours param passed
          if ((params.date && params.date.indexOf(dayObj.day) === -1)
            || (!params.date && dayObj.day !== todayString)
            || params.noHours) {
            return;
          }

          var hoursKey = util.format('stream:%s:countType:counts:day:%s:hours', stream.name, dayObj.day);
          return client.zrangeAsync(hoursKey, 0, -1).map(function(hourKey) {
            return client.hgetallAsync(hourKey);
          }).map(function(hourObj) {
            // only get requested hours
            if (params.hour && params.hour.indexOf(hourObj.hour) === -1) {
              return;
            }

            // remove stream name from hour object
            delete hourObj.streamName;

            // add direct votes to hour count
            return client.zrangeAsync('sources', 0, -1).map(function(source) {
              var sourceString = '';
              if (source.length > 0) {
                sourceString = '-' + source;
              }
              var directVotesHourKey = util.format('team:%s:countType:directVotes%s:day:%s:hour:%s', stream.team, sourceString, hourObj.day, hourObj.hour);
              return client.hgetAsync(directVotesHourKey, 'count').then(function(obj) {
                var directVoteCount = 0;
                if (obj) {
                  directVoteCount = parseInt(obj);
                }
                if (!excludeDirectVotes) {
                  hourObj.count = (parseInt(hourObj.count) + directVoteCount).toString();
                }
              })
            }).then(function() {
              json[stream.name].hours.push(hourObj);
            });
          });
        });
      });
    }).then(function() {
      // filterStreams(json);
      resolve(json);
    });
  });
}

function stateCountsJSON(params) {
  // ensure team, date, hour params are arrays
  if (params.team && params.team.constructor !== Array) {
    params.team = [params.team];
  }
  if (params.date && params.date.constructor !== Array) {
    params.date = [params.date];
  }
  if (params.hour && params.hour.constructor !== Array) {
    params.hour = [params.hour];
  }

  if (!params.numDays) {
    params.numDays = 7;
  }

  return new Promise(function(resolve) {
    var todayString = adjustedDate(moment()).format("YYYY-MM-DD");

    var json = {};

    var numDays = {};

    client.zrevrangeAsync('streams', 0, -1).map(function(streamKey) {
      return client.hgetallAsync(streamKey);
    }).map(function(stream) {
      // only get requested teams
      if (params.team && params.team.indexOf(stream.team) === -1) {
        return;
      }

      json[stream.name] = {
        'team': stream.team,
        'days': [],
        'hours': []
      }

      numDays[stream.name] = 0;

      var daysKey = util.format('stream:%s:countType:stateCounts:days', stream.name);
      return client.zrevrangeAsync(daysKey, 0, -1).map(function(dayKey) {
        return client.hgetallAsync(dayKey);
      }).map(function(dayObj) {
        // only get requested days
        if (params.date && params.date.indexOf(dayObj.day) === -1) {
          return;
        }

        // only get up to param.numDays
        if (numDays[stream.name] >= params.numDays) {
          return;
        }

        // remove stream name from day object
        delete dayObj.streamName;

        numDays[stream.name]++;

        json[stream.name].days.unshift(dayObj);

        var dayStatesKey = util.format('stream:%s:countType:stateCounts:day:%s:states', stream.name, dayObj.day);
        return client.zrangeAsync(dayStatesKey, 0, -1).map(function(dayStateKey) {
          return client.hgetallAsync(dayStateKey);
        }).map(function(dayStateObj) {
          var days = json[dayStateObj.streamName].days;
          var day = _.find(days, function(day) {
            return day.day === dayStateObj.day;
          });
          if (typeof(day.states) === 'undefined') {
            day.states = [];
          }

          // remove stream name, day from day state object
          delete dayStateObj.streamName;
          delete dayStateObj.day;

          day.states.push(dayStateObj);
        }).then(function() {
          // 3 conditions under which we skip hours
          // 1) day array provided and day isn't requested
          // 2) no day array provided and day isn't current day
          // 3) noHours param passed
          if ((params.date && params.date.indexOf(dayObj.day) === -1)
            || (!params.date && dayObj.day !== todayString)
            || params.noHours) {
            return;
          }

          var hoursKey = util.format('stream:%s:countType:stateCounts:day:%s:hours', stream.name, dayObj.day);
          return client.zrangeAsync(hoursKey, 0, -1).map(function(hourKey) {
            return client.hgetallAsync(hourKey);
          }).map(function(hourObj) {
            // only get requested hours
            if (params.hour && params.hour.indexOf(hourObj.hour) === -1) {
              return;
            }

            // remove stream name from hour object
            delete hourObj.streamName;

            json[stream.name].hours.push(hourObj);

            var hourStatesKey = util.format('stream:%s:countType:stateCounts:day:%s:hour:%s:states', stream.name, hourObj.day, hourObj.hour);
            return client.zrangeAsync(hourStatesKey, 0, -1).map(function(hourStateKey) {
              return client.hgetallAsync(hourStateKey);
            }).map(function(hourStateObj) {
              var hours = json[hourStateObj.streamName].hours;
              var hour = _.find(hours, function(hour) {
                return hour.day === hourStateObj.day && hour.hour === hourStateObj.hour;
              });
              if (typeof(hour.states) === 'undefined') {
                hour.states = [];
              }

              // remove stream name, hour from hour state object
              delete hourStateObj.streamName;
              delete hourStateObj.day;
              delete hourStateObj.hour;

              hour.states.push(hourStateObj);
            });
          });
        });
      });
    }).then(function() {
      // filterStreams(json);
      resolve(json);
    });
  });
}

// streams
server.get('/streams', function (req, res, next) {
  var streams = clone(streamData.streams);

  // sort streams by stream name in descending order
  streams.sort(function(a, b) {
    if (a.name < b.name) return -1;
    if (a.name > b.name) return 1;
    return 0;
  });

  res.send(streams);
});

// counts
server.get('/counts', function (req, res, next) {
  var json = countsJSON(req.params).then(function(json) {
    res.send(json);
  });
  
  return next();
});

// current counts (current day counts, no hours)
server.get('/currentCounts', function (req, res, next) {
  req.params.date = [ adjustedDate(moment()).format("YYYY-MM-DD") ];
  req.params.noHours = true;

  var json = countsJSON(req.params).then(function(json) {
    res.send(json);
  });
  
  return next();
});

// state counts
server.get('/stateCounts', function (req, res, next) {
  var json = stateCountsJSON(req.params).then(function(json) {
    res.send(json);
  });

  return next();
});

// current state counts  (current day counts, no hours)
server.get('/currentStateCounts', function (req, res, next) {
  req.params.date = [ adjustedDate(moment()).format("YYYY-MM-DD") ];
  req.params.noHours = true;

  var json = stateCountsJSON(req.params).then(function(json) {
    res.send(json);
  });
  
  return next();
});

server.get('/countsBySource', function (req, res, next) {
  var dateString = req.params.date;

  if (!dateString) {
    dateString = adjustedDate(moment()).format("YYYY-MM-DD");
  }

  if (req.params.team && req.params.team.constructor !== Array) {
    req.params.team = [req.params.team];
  }

  var json = {};

  client.zrevrangeAsync('streams', 0, -1).map(function(streamKey) {
    return client.hgetallAsync(streamKey);
  }).map(function(stream) {
    // only get requested teams
    if (req.params.team && req.params.team.indexOf(stream.team) === -1) {
      return;
    }

    json[stream.name] = {
      team: stream.team,
      date: dateString,
      sources: []
    };
    var sources = ['social', 'microsite-pick', 'microsite-zip', 'vph', 'other'];
    return Promise.map(sources, function(source) {
      var key;
      if (source === 'social') {
        key = util.format('stream:%s:countType:counts:day:%s', stream.name, dateString);
      } else {
        var sourceString = '';
        if (['microsite-pick', 'microsite-zip', 'vph'].indexOf(source) !== -1) {
          sourceString = '-' + source;
        }

        key = util.format('team:%s:countType:directVotes%s:day:%s', stream.team, sourceString, dateString);
      }
      return client.hgetallAsync(key).then(function(directVote) {
        var count = 0;
        if (directVote) {
          count = directVote.count;
        }
        json[stream.name].sources.push({
          source: source,
          count: count
        });
      });
    });
  }).then(function() {
    res.send(json);
  });

  return next();
});

server.post('/postVote', function create(req, res, next) {
  var vote = req.params;

  // check for team param and validate
  var teams = _.map(streamData.streams, function(stream) {
    return stream.team;
  });
  if (typeof vote.team === 'undefined' || teams.indexOf(vote.team) === -1) {
    res.send({'success': false, 'error': 'Please provide a valid team: [' + teams + ']'});
    return next();
  }

  var date = adjustedDate(moment());
  var dateString = date.format("YYYY-MM-DD");

  var sources = ['microsite-pick', 'microsite-zip', 'vph', 'other'];

  // check for source param and validate
  if (typeof vote.source === 'undefined' || sources.indexOf(vote.source) === -1) {
    res.send({'success': false, 'error': 'Please provide a valid source: [' + sources + ']'});
    return next();
  }

  /*
   * Redis keys by source:
   *
   * microsite-pick: directVotes-microsite-pick:
   * microsite-zip:  directVotes-microsite-zip:
   * vph:            directVotes-vph:
   * other:          directVotes:
   * 
   */
  var sourceString = '';
  if (sources.indexOf(vote.source) !== -1) {
    if (vote.source !== 'other') {
      sourceString = ('-' + req.params.source);
    }
  }

  var dayKey = util.format('team:%s:countType:directVotes%s:day:%s', vote.team, sourceString, dateString);
  try {
    clientAlgo.hmset(dayKey, vote);
    clientAlgo.hincrby(dayKey, 'count', 1);
  } catch (e) {
    res.send({'success': false});
    return next();
  }

  var hourKey = util.format('team:%s:countType:directVotes%s:day:%s:hour:%s', vote.team, sourceString, dateString, date.hour());
  try {
    clientAlgo.hmset(hourKey, vote);
    clientAlgo.hincrby(hourKey, 'count', 1);
  } catch (e) {
    res.send({'success': false});
    return next();
  }

  res.send({'success': true});
  return next();
});

server.listen(3000, function () {
  console.log('%s listening at %s', server.name, server.url);
});