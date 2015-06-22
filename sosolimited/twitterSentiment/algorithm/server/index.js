
// dependencies
var _ = require("underscore");
var Q = require("q");
var nano = require("nano");
var request = require('request');
var moment = require('moment');
var winston = require("winston");

var sys = require('sys');
var exec = require('child_process').exec;

// logging
function logTimestamp() {
  return moment().format("YYYY-MM-DDTHH:mm");
}

var logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)({ colorize: true, json: false, timestamp: logTimestamp }),
    new (winston.transports.File)({ filename: __dirname + "/../" + "log.txt", colorize: true, json: false, timestamp: logTimestamp })
  ]
});

// config file
var config = require(__dirname + "/../../config.json");

// SentiStrength object
var SentiStrength = require(__dirname + "/../strategy/java-network");

// datasift
var DataSift = require("datasift");

// amount of time to wait before trying to reconnect to datasift
var RECONNECT_DELAY = 1000;

// how often to check datasift stream rates
var CHECK_STREAM_RATES_INTERVAL = 1 * 60 * 1000;  // 1 min

// max allowed tweets / 24 hour period via datasift
var DAILY_TWEET_LIMIT = config.DAILY_TWEET_LIMIT;

logger.info("Sosolimited Twitter Algorithm Server");
logger.info("Root Directory: " + __dirname);
logger.info("Daily Tweet Limit: " + DAILY_TWEET_LIMIT);

// couchdb
var url = config.couch.master.url;
logger.info("CouchDB URL: " + url);

var db = nano(url);
var insertDocs = { docs: [] };
var lastInsertTime = Date.now();

// datasift consumers
var consumers = {};

// sentistrength instances
var ss;

// zero count check for given interval for each stream
var zeroCountCheck = {};

/*
 * 1) Creates and initializes sentistrength processes and makes sure they're up and running.
 * 2) Validate the CSDL for each stream in the config.
 * 3) Initialize the stream rate info.
 * 3) Start datasift consumer.
 */
createAndInitializeSentiStrengthInstances()    // 1)
.then(validateStreams)  // 2)
.then(function(dpus) {
  // verify that the actual vs expected DPU values match
  var actual = dpus;
  var expected = _.values(config.datasift.streams).map(function(stream) { return stream.dpu; });
  var difference = _.difference(expected, actual);

  // logger.info(actual + " " + expected);

  if (difference.length > 0) {
    throw new Error ('Stream DPUs do not match.');
  }

  return initializeStreamRateInfo();  // 3)
})
.then(startDatasift)    // 4)
.catch(function(error) {
  logger.error(error);
});

/**
 * Creates and initializes sentistrength instances.
 * Spawns underlying java process for each.
 * 
 * @return {Promise} A promise for the array of promises.
 */
function createAndInitializeSentiStrengthInstances() {
  var ssTeams = [];
  var questions = config.questions;
  for (var questionName in questions) {
    var question = questions[questionName];

    var questionSSTeams = _.values(question.ss).map(function(ssKey) {
      if (ssKey === "generic") {
        return ssKey;
      } else {
        return question[question.ss[ssKey]];
      }
    });

    ssTeams = ssTeams.concat(questionSSTeams);
  }

  ssTeams = _.uniq(ssTeams);

  ss = {};
  ssTeams.forEach(function(ssTeam) {
    ss[ssTeam] = new SentiStrength(ssTeam);
  });
  
  var promises = _.values(ss).map(function(ssObj) {
    return ssObj.spawnProcess();
  });
  return Q.all(promises);
}

/**
 * Validates the CSDL of the streams in the config.
 * 
 * @return {float} A DataSift DPU cost value of the validated stream's CSDL.
 */
function validateStreams() {
  var streams = config.datasift.streams;
  var promises = _.values(streams).map(function(stream) {
    var encodedCSDL = encodeURIComponent(stream["csdl"].join(" "));

    var key = stream.key;
    var user = config.datasift.accounts[key].user;

    var dfd = Q.defer();

    request.post('http://api.datasift.com/v1/validate?csdl='+encodedCSDL, {
      'headers': {
        "Authorization": user+":"+key
      },
      'strictSSL': false
    }, function(error, response, body) {
      var json = JSON.parse(body);
      if (json.error) {
        logger.error(json);
        dfd.reject(new Error("Invalid CSDL for stream: " + stream["question"]+"/"+stream["team"]));
      } else {
        var dpu = parseFloat(json.dpu);
        dfd.resolve(dpu);
      }
    });

    return dfd.promise;
  });

  return Q.all(promises);
}

/**
 * Initializes the streams loaded into memory from the config
 * compiled with sample rate = 100 and count = 0.
 *
 * Initially compiling with an explicit interaction.sample value is necessary
 * since when not specified, it's an internally generated floating-point random number
 * between 0 and 100.  (http://dev.datasift.com/docs/targets/common-interaction/interaction-sample)
 * 
 * @return {Promise} A promise signaling when all the streams are initialized.
 */
function initializeStreamRateInfo() {
  var promises = [];

  var streams = config.datasift.streams;
  for (var streamHash in streams) {
    promises.push( adjustStreamSample(streamHash, 100) );
  }

  return Q.all(promises);
}

/**
 * Starts the DataSift consumer.
 */
function startDatasift() {
  lastInsertTime = Date.now();

  logger.info("Connecting to DataSift accounts");

  var accounts = _.values(config.datasift.accounts);
  accounts.forEach(function(account) {
    var user = account.user;
    var key = account.key;

    consumers[key] = new DataSift(user, key);
    consumers[key].connect();

    // connect
    consumers[key].on("connect", function() {
      var streams = config.datasift.streams;
      for (var streamHash in streams) {
        var streamKey = streams[streamHash].key;
        if (streamKey === key) {
          consumers[key].subscribe(streamHash);
          logger.info("Subscribing to stream: " + streamHash)
        }
      }
    });

    // disconnect
    consumers[key].on("disconnect", function() {
      logger.info("Disconnected from DataSift. Attempting to reconnect...");

      setTimeout(function() {
        consumers[key].connect();
      }, RECONNECT_DELAY);
    });

    // error
    consumers[key].on("error", function(error) {
      logger.error(error);
    });
    
    // warning
    consumers[key].on("warning", function(message, json) {
      var stream = config.datasift.streams[json.hash];
      var streamLabel = stream.question+"/"+stream.team;
      logger.warn(message + " ("+streamLabel+")");
    });

    // interaction
    consumers[key].on("interaction", function(receivedData) {
      try {
        var hash = receivedData.hash;
        var data = receivedData.data;

        handleInteraction(hash, data);
      } catch (error) {
        logger.error("Received data with unexpected format. Skipping. " + error)
      }
    });
  });

  // start usage check
  setInterval(function() {
    checkStreamRates();
  }, CHECK_STREAM_RATES_INTERVAL);
}

/**
 * Runs the SentiStrength instances against a stream.
 * 
 * @param  {String} hash The stream's hash.
 * @param  {Object} data The interaction object.
 */
function handleInteraction(hash, data) {
  var twitter = data.twitter;

  if (!twitter.text) {
    return;
  }

  // give indication some data was retrieved
  logger.info("Data received: " + twitter.created_at);

  // increment count for given stream
  config.datasift.streams[hash].count++;

  var text = twitter.text;

  // given the stream, determine which sentistrength instances to run against text
  var ssToRun = [];

  var streamQuestion = config.datasift.streams[hash].question;
  var streamTeam = config.datasift.streams[hash].team;

  var questions = config.questions;
  var question = questions[streamQuestion];

  var team = question[streamTeam];
  var ssType = question.ss[streamTeam];

  if (ssType === "" || ssType === "generic") {
    ssToRun.push(ss["generic"]);
  } else {
    ssToRun.push(ss[team]);
  }

  var promises = ssToRun.map(function(ssObj) {
    return ssObj.analyze(text);
  });

  // gather all the sentiment data for the stream and then insert it into the db
  Q.all(promises).then(function(sentiments) {
    try {
      insertInteraction(hash, data, sentiments);
    } catch(error) {
      logger.error("Unable to insert interaction. " + error)
    }
  }, function(error) {
    logger.error("Failed running sentistrength on text: " + text + " " + error)
  });
}

/**
 * Inserts the interaction info into the database.
 * 
 * @param  {String} hash       Stream hash.
 * @param  {Object} data       The interaction object.
 * @param  {Array}  sentiments Array of sentiment arrays.
 */
function insertInteraction(hash, data, sentiments) {
  // stream info
  var streamInfo = config.datasift.streams[hash];

  // question
  var question = streamInfo.question;

  // team
  var streamTeam = streamInfo.team;

  // check screenname and user name for dirty words
  _.each(sentiments, function(sentiment, i) {
    var ssTeam = sentiment[4];

    if (!sentiment[3]) {
      // assuming the dirty words list for all sentistrength instances are the same
      sentiment[3] = ss[ssTeam].checkDirty(data.twitter.user.name + data.twitter.user.screen_name);
    }
  });

  // twitter data
  var twitter = {};
  twitter.id = data.twitter.id;
  twitter.created_at = data.twitter.created_at;

  // don't include twitter text in cloudant storage
  if (db.config.url.indexOf("cloudant") === -1) {
    twitter.text = data.twitter.text;
  }

  // create a document for each sentistrength result
  _.each(sentiments, function(sentiment, i) {
    var ssType = sentiment[4];

    logger.info('Adding doc to be inserted: (stream: '+question+'/'+streamTeam+', ss: '+ssType+')');

    data = {
      _id: twitter.id + "_" + question + "_" + streamTeam,
      question: question,
      team: streamTeam,
      twitter: twitter,
      sentiment: sentiment,
      coefficient: 100 / streamInfo.sample
    };

    insertDocs.docs.push(data);
  });

  if (insertDocs.docs.length >= 500 || (Date.now() - lastInsertTime > 10000 && insertDocs.docs.length > 0)) {
    db.bulk(insertDocs, function() {
      logger.info("INSERTED DOCS: " + insertDocs.docs.length);
      insertDocs.docs = [];
      lastInsertTime = Date.now();
    });
  }
}

/**
 * Checks the stream rates for the last CHECK_STREAM_RATES_INTERVAL.
 */
function checkStreamRates() {
  var streams = config.datasift.streams;
  for (var streamHash in streams) {
    var stream = streams[streamHash];
    var streamLabel = stream.question+"/"+stream.team;
    var streamKey = stream.key;

    var intervalInMinutes = CHECK_STREAM_RATES_INTERVAL / (1000 * 60);

    var currentSample = stream.sample;

    var streamCount = stream.count;
    var adjustedCount = streamCount * (100 / currentSample);

    // max allowed tweets for given interval for this stream
    var numStreamsOnThisAccount = _.values(streams).filter(function(x) { return x.key === streamKey; }).length;
    var streamRateLimit = DAILY_TWEET_LIMIT / (numStreamsOnThisAccount * 1440 * 1.3);  // 1.3 padding just in case

    var adjustedSample = (streamRateLimit * intervalInMinutes) / adjustedCount;
    adjustedSample = Math.min(adjustedSample * 100, 100);
    adjustedSample = Math.max(adjustedSample, 0.01);

    logger.info("counts: " + streamCount + " " + adjustedCount + " " + streamRateLimit*intervalInMinutes + " " + currentSample + " -> " + adjustedSample + "  ("+streamLabel+")");

    // check to see if the stream has flatlined
    if (streamCount === 0) {
      // increment stream's zero count
      if (streamLabel in zeroCountCheck) {
        zeroCountCheck[streamLabel]++;
      } else {
        zeroCountCheck[streamLabel] = 1;
      }

      // calculate flatline threshold depending on current hour
      var flatlineThreshold = 15;

      // increase threshold for off-peak hours
      var hour = moment(moment().valueOf() - (5-(moment().zone()/60))*60*60*1000).hour();
      if (hour < 8) {
        flatlineThreshold = 25;
      }

      // check if game stream consecutive zero count exceeds flatline threshold
      if (zeroCountCheck[streamLabel] >= flatlineThreshold && stream.question !== "espn") {
        // try to resubscribe to stream
        if (consumers[streamKey]) {
          consumers[streamKey].subscribe(streamHash);
        }

        var flatLineMessage = streamLabel + " flatlined";

        // log error
        logger.error(flatLineMessage);

        // send email alert
        if (stream.question === "game") {
          exec('mail -s "prod-algo: '+flatLineMessage+'" wgw@sosolimited.com < /dev/null');
        }
        
        // reset stream's zero count
        zeroCountCheck[streamLabel] = 0;
      }
    } else {
      zeroCountCheck[streamLabel] = 0;
    }

    // reset stream count for next interval check
    stream.count = 0;

    // only adjust stream if new coefficient differs from curent one by a certain amount
    var minSample = Math.min(currentSample, adjustedSample);
    var maxSample = Math.max(currentSample, adjustedSample);
    var ratio = minSample / maxSample;

    if (ratio <= 0.65) {
      adjustStreamSample(streamHash, adjustedSample);
    }
  }
}

/**
 * Adjusts stream by dynamically compiling new stream with new interaction.sample value.
 * 
 * @param  {String} streamHash Stream hash.
 * @param  {int}    newSample  New interaction.sample value.
 */
function adjustStreamSample(streamHash, newSample) {
  var streams = config.datasift.streams;
  var stream = streams[streamHash];
  var streamLabel = stream.question+"/"+stream.team;

  var key = stream.key;
  var user = config.datasift.accounts[key].user;

  // unsubscribe from stream
  if (consumers[key]) {
    consumers[key].unsubscribe(streamHash);
  }

  // compile new stream with adjusted sample
  var csdl = clone(stream.csdl);
  csdl.unshift("interaction.sample <= " + newSample + " AND (");
  csdl.push(")");
  csdl = csdl.join(" ");

  // console.log(csdl);

  var encodedCSDL = encodeURIComponent(csdl);

  var dfd = Q.defer();

  request.post('http://api.datasift.com/v1/compile?csdl='+encodedCSDL, {
    'headers': {
      "Authorization": user+":"+key
    },
    'strictSSL': false
  }, function(error, response, body) {
    var json = JSON.parse(body);
    if (json.error) {
      // in case of error, stick with current hash
      if (consumers[key]) {
        consumers[key].subscribe(streamHash);
      }

      // show error when trying to adjust stream
      var str = body + " ("+streamLabel+")";
      logger.error(str);
      exec('mail -s "prod-algo: adjust-stream error" wgw@sosolimited.com <<< "'+str+'"');

      dfd.reject(new Error("Unable to adjust stream: " + streamLabel));
    } else {
      // show that the stream was adjusted
      logger.info(body + " ("+streamLabel+")");

      var newHash = json.hash;
      var oldHash = streamHash;

      // update stream in config  (NOTE: compiled stream does not persist)
      streams[newHash] = streams[oldHash];
      delete streams[oldHash];

      streams[newHash].count = 0;
      streams[newHash].sample = newSample;

      // subscribe to new stream
      if (consumers[key]) {
        consumers[key].subscribe(newHash);
      }
      
      dfd.resolve(newHash);
    }
  });

  return dfd.promise;
}

/**
 * Kills each SentiStrength object's underlying java process.
 */
function cleanup() {
  _.each(_.values(ss), function(ssObj) {
    ssObj.cleanup();
  });
}

function clone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

process.on('exit', function() {
   cleanup();
});

// triggered when killing program via Ctrl+C
process.on('SIGINT', function() {
   process.exit();
});
