
var Miso = require("miso.dataset");
var _ = require('lodash');
// var _ = require("underscore");
// _.mixin(require("underscore.deferred"));

_.mixin({
  movingAvg : function(arr, size, method) {
    method = method || _.mean;
    var win, i, newarr = [];
    for(i = size-1; i <= arr.length; i++) {
      win = arr.slice(i-size, i);
      if (win.length === size) {
        newarr.push(method(win)); 
      }
    }
    return newarr;
  }
});

var ds = new Miso.Dataset({
  data: [
    {key:"AZ", value:130000},
    {key:"AZ", value:420},
    {key:"AZ", value:1000},
    {key:"MA", value:200},
    {key:"MA", value:2900},
    {key:"MA", value:4}
  ]
});

var ds2 = new Miso.Dataset({
  data: {
    columns: [
      { name : "A", data : [1,2,3,4,5,6,7,8,9,10],           type : "numeric" },
      { name : "B", data : [10,9,8,7,6,5,4,3,2,1],           type : "numeric" },
      { name : "C", data : [10,20,30,40,50,60,70,80,90,100], type : "numeric" }
    ]
  },
  strict: true
});

// count by
ds.fetch({ 
  success: function() {
    var x = this.countBy('key');
    x.each(function(row) {
      delete row._id;
      delete row._oids;
      console.log(row);
    });
  }
});
console.log();

// group by
ds.fetch({ 
  success: function() {
    var x = this.groupBy('key', ['value']);
    x.each(function(row) {
      delete row._id;
      delete row._oids;
      console.log(row);
    });
  }
});
console.log();

// moving average
ds2.fetch({ 
  success: function() {
    var x = this.movingAverage(["A"]);
    this.each(function(row) {
      delete row._id;
      delete row._oids;
      console.log(row);
    });
  }
});
console.log();
