
var Miso = require("miso.dataset");
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

ds.fetch({ 
  success: function() {
    var gb = this.countBy('key');
    gb.each(function(row) {
      delete row._id;
      delete row._oids;
      console.log(row);
    });
  }
});