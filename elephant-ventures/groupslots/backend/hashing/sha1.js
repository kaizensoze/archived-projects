
var crypto = require('crypto')
  , prompt = require('prompt');

prompt.get(['input'], function(err, result) {
  var salt = crypto.randomBytes(64).toString('hex');
  var hash = crypto.createHmac('sha1', salt).update(result.input).digest('hex');
  console.log(hash);
});
