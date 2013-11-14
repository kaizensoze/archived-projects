
var Miso = require("miso.dataset");
var _ = require('lodash');
// var _ = require("underscore");
// _.mixin(require("underscore.deferred"));

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
  data: [
    {key:"A", value:130000},
    {key:"B", value:420},
    {key:"C", value:1000},
    {key:"D", value:200},
    {key:"E", value:2900},
    {key:"F", value:4}
  ]
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
    var x = this.movingAverage('value');
    x.each(function(row) {
      delete row._id;
      delete row._oids;
      console.log(row);
    });
  }
});
console.log();
