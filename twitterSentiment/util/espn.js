
var request = require("request");

setInterval(function() {
  getESPNData();
}, 2 * 1000); // every minute

function getESPNData() {
  // afc
  request('http://api.massrelevance.com/compare.json?streams=BristolDev/super-bowl-hashtag-battle-answer-2', function (error, response, body) {
    var json = JSON.parse(body);
    var count = json.streams[0].count.approved;
    console.log(count);
  });

  // nfc
  request('http://api.massrelevance.com/compare.json?streams=BristolDev/super-bowl-hashtag-battle-answer-1', function (error, response, body) {
    var json = JSON.parse(body);
    var count = json.streams[0].count.approved;
    console.log(count);
  });
}