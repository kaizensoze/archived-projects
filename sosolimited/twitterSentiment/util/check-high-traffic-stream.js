
var config = require(__dirname + "/../config.json");
var request = require('request');
var DataSift = require("datasift");

var CHECK_STREAM_RATES_INTERVAL = .5 * 60 * 1000;  // 30 secs
var DAILY_TWEET_LIMIT = config.DAILY_TWEET_LIMIT;
var STREAM_RATE_LIMIT = 50;

var streamHash = "f735553d0ca799eddae22546107a874a";

var consumer;
var streamCount = 0;
var streamSample = 100;

consumer = new DataSift(config.datasift.user, config.datasift.key);
consumer.connect();

consumer.on("connect", function() {
  consumer.subscribe(streamHash);

  setInterval(function() {
    checkStreamRates();
  }, CHECK_STREAM_RATES_INTERVAL);
});

consumer.on("error", function(error) {
  console.log(error);
});

consumer.on("warning", function(message) {
  console.log("warning: " + message);
});

consumer.on("interaction", function(interaction) {
  var twitter = interaction.data.twitter;
  console.log("Data received:", twitter.created_at);
  streamCount++;
});

function checkStreamRates() {
  var intervalInMinutes = CHECK_STREAM_RATES_INTERVAL / (1000 * 60);
  var adjustedSample = (STREAM_RATE_LIMIT*intervalInMinutes) / streamCount;
  adjustedSample = Math.min(adjustedSample*100, 100);

  // instead of directly increasing sample to 100, increase gradually
  var gradualIncreaseAmount = 10;
  var gradualIncrease = false;
  if (adjustedSample === 100 && streamSample < 100) {
    adjustedSample = Math.min(streamSample + gradualIncreaseAmount, 100);
    gradualIncrease = true;
  }

  var gradualIncreaseNote = "";
  if (gradualIncrease) {
    gradualIncreaseNote = " (gradual +"+gradualIncreaseAmount+")";
  }
  console.log(streamCount + " " + STREAM_RATE_LIMIT*intervalInMinutes + " -> " + adjustedSample + gradualIncreaseNote);

  // reset stream count
  streamCount = 0;

  if (Math.abs(streamSample - adjustedSample) > 5) {
    adjustStreamSample(streamHash, adjustedSample);
  }
}

function adjustStreamSample(_streamHash, newSample) {
  // unsubscribe from stream
  if (consumer) {
    consumer.unsubscribe(_streamHash);
  }

  var encodedCSDL = encodeURIComponent('twitter.text substr "dream" AND twitter.user.lang in "en" AND interaction.sample <= '+newSample);

  request.post('http://api.datasift.com/v1/compile?csdl='+encodedCSDL, {
    'headers': {
      "Authorization": config.datasift.user+":"+config.datasift.key
    },
    'strictSSL': false
  }, function(error, response, body) {
    console.log(body);

    var json = JSON.parse(body);
    if (json.error) {
      console.log(json.error);
    } else {
      streamHash = json.hash;

      streamSample = newSample;
      streamCount = 0;

      // subscribe to new stream
      if (consumer) {
        consumer.subscribe(streamHash);
      }
    }
  });
}