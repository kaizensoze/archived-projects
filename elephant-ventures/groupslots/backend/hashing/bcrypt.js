
var bcrypt = require('bcrypt');

var salt = bcrypt.genSaltSync(10);
var hash = bcrypt.hashSync("testPassword", salt);
var positiveMatch = bcrypt.compareSync("testPassword", hash);
var negativeMatch = bcrypt.compareSync("bacon", hash);

console.log(hash, positiveMatch, negativeMatch);