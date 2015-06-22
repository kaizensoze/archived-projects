
var config = require(__dirname + "/../config.json");
var nano = require("nano");
var moment = require("moment");

var url = config.couch.master.url;
var db = nano(url);

var params = {
  include_docs: true,
  descending: true
};

var start = moment("2014-01-19T09:30:00 -0500", "YYYY-MM-DDTHH:mm:ss Z");
var end = moment("2014-01-19T10:30:00 -0500", "YYYY-MM-DDTHH:mm:ss Z");

var docsToRemove = { docs: [] };

db.list(params, function(err, body) {
  if (err) {
    console.log(err);
    return false;
  }

  body.rows.forEach(function(doc) {
    var doc = doc.doc;

    // skip design docs
    if (doc._id.indexOf("_design") !== -1) {
      return;
    }

    var docDate = moment(doc.twitter.created_at);

    // add doc to be removed if within desired span of time
    if (docDate.isAfter(start) && docDate.isBefore(end)) {
      console.log(docDate.toString());
      doc._deleted = true;
      docsToRemove.docs.push(doc);
    }
  });

  // remove docs
  db.bulk(docsToRemove, function() {
    console.log("DELETED DOCS:", docsToRemove.docs.length);
  });
});
