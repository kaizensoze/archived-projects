var App = {};

App.ServiceHandler = Class.extend({
    url: 'service.php',
    
    init: function() {
    },
    
    request: function(options) {
        var me = this;
        
        $.ajax({
            type: "post",
            //contentType: 'application/json; charset=utf-8',
            url: me.url,
            data: options.data,
            success: function (result) {
                if (options.callback.length != 0)
                    options.callback(result);
            }
        });
    }
});

$(document).ready(function() {
    var changeBrand = $(".change-brand");
    var brands = $("#brands");
    
	$("#groups").load('admin.php?action=groups', function() {
		$(".details_link").click(function(evt) {
			evt.preventDefault();
			
			var group_id = this.id.split('_')[0];
			$("#current_group").html("Group " + group_id).show();
			$("#group_details").load('admin.php?action=group_details&group_id='+group_id);
		});
	});
      
	$("#change_casino").click(function() {
	    changeBrand.slideDown(100);
	});
	
	changeBrand.find(".change-btn").click(function() {
	    var brand = brands.val();
	    if(brand == '-1')
		return;
	    
	    var data = "action=setBrand&brand=" + brand;
	    
	    App.Service.request({
		data: data,
		callback: function(response){
		    window.location.reload();
		}
	    });
	    changeBrand.slideUp(100);
	});
	
	changeBrand.find(".cancel-btn").click(function() {
	   changeBrand.slideUp(100); 
	});
      
      var helpBlurb = $(".help-blurb");
      helpBlurb.find("#hide").click(function(e) {
	e.preventDefault();
	e.stopPropagation();
	helpBlurb.hide();
      });
      
      App.Service = new App.ServiceHandler();
});
