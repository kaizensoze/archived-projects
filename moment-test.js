
var moment = require("moment");
var _ = require("underscore");
var m = moment.utc().format("YYYY-MM-DDTHH:mm");

var A = _.range(50);
var num = 10;
var check = A.length/num;

var subset = _.filter(A, function(i, x) {
	return i % check == 0;
});

_.each(_.range(10), function(x) {
	console.log(x);
});

