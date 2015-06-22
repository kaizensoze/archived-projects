
var config = require(__dirname + "/../config.json");
var nano = require("nano");
var _ = require("underscore");

var url = config.couch.slave.url;
var db = nano(url);

var params = {
    include_docs: true,
    descending: true
};

db.list(params, function(err, body) {
  if (err) {
    console.log(err);
    return false;
  }

  var count = 0;
  var results = [];

  _.each(body.rows, function(doc) {
    // skip design documents
    if (doc.id[0] == '_') {
      return true;  // continue
    }

    if (doc.doc.question+'/'+doc.doc.team === 'game/nfc') {
      count += doc.doc.coefficient;
      results.push(doc.doc.twitter.created_at + ' ' + doc.doc.coefficient);
    }
  });

  results.sort();

  for (var i=0; i < results.length; i++) {
    console.log(results[i]);
  }

  console.log(count);
});
