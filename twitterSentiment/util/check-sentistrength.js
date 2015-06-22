
var _ = require("underscore");
var Q = require("q");
var SentiStrength = require(__dirname + "/../algorithm/strategy/java-network");

var text = process.argv[2];

if (!text) {
  console.log('Please pass a text string.\nFormat: node check-sentistrength.js <text>\n');
  process.exit();
}

var ss = [
  new SentiStrength("generic"),
  new SentiStrength("afc"),
  new SentiStrength("nfc")
];

var promises = ss.map(function(ssObj) {
  return ssObj.spawnProcess();
});

Q.all(promises)
.then(function(pids) {
  getSentiments()
  .then(function(sentiments) {
    _.each(sentiments, function(sentiment) {
      console.log(sentiment);
    });
    process.exit();
  });
});

function getSentiments() {
  var promises = ss.map(function(ssObj) {
    return ssObj.analyze(text);
  });
  var promise = Q.all(promises);
  return promise;
}

function cleanup() {
  _.each(ss, function(ssObj) {
    ssObj.cleanup();
  });
}

process.on('exit', function() {
   cleanup();
});

// triggered when killing program via Ctrl+C
process.on('SIGINT', function() {
   process.exit();
});
