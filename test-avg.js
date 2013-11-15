
var _ = require("underscore");

// http://www.mathworks.com/help/curvefit/smoothing-data.html#bq_6ys3-1

var A = [10, 15, 6, 2, 20, 9];
var averages = [];

_.each(A, function(x, i) {
  var n = _.min([i, A.length-i-1]);
  averages[i] = avg(i, n);
});

function avg(i, n) {
  var slice = A.slice(i-n, i+n+1);
  var sum = _.reduce(slice, function(x, y) { return x + y; }, 0);
  var result = sum / (2*n+1);
  return result;
}

/*

[ 10, 15, 6, 2, 20, 9 ]
[ 10, 10.333333333333334, 10.6, 10.4, 10.333333333333334, 9 ]

min(i-0, A.length-i)

i=0 min(0,5) => n=0 => A[i-n .. i+n+1] => A.slice(0, 1)
i=1 min(1,4) => n=1 => A[i-n .. i+n+1] => A.slice(0, 3)
i=2 min(2,3) => n=2 => A[i-n .. i+n+1] => A.slice(0, 5)
i=3 min(3,2) => n=2 => A[i-n .. i+n+1] => A.slice(1, 6)
i=4 min(4,1) => n=1 => A[i-n .. i+n+1] => A.slice(3, 6)
i=5 min(5,0) => n=0 => A[i-n .. i+n+1] => A.slice(5, 6)

get distance from each end
take the min

*/