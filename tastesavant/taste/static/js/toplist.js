window.addEvent('domready', function() {

	$('toplist-left').addEvent('click', function (evt) {
        var toplist_entries = $$('.toplist-entry-outer');

        var first_set = toplist_entries.slice(0,6);
        var second_set = toplist_entries.slice(4,10); // keep last element from first set

        // If first set is already shown, don't do anything.
        if (first_set[0].getStyle('display') == 'inline-block') {
            return;
        }

        second_set.each(function(item, idx) {
            item.setStyle('display', 'none');
        });
        first_set.each(function(item, idx) {
            item.setStyle('display', 'inline-block');
        });
    });

    $('toplist-right').addEvent('click', function (evt) {
        var toplist_entries = $$('.toplist-entry-outer');
    
        var first_set = toplist_entries.slice(0,6);
        var second_set = toplist_entries.slice(4,10); // keep last element from first set
    
        // If second set is already shown, don't do anything.
        if (second_set[2].getStyle('display') == 'inline-block') {
            return;
        }
    
        first_set.each(function(item, idx) {
            item.setStyle('display', 'none');
        });
        second_set.each(function(item, idx) {
            item.setStyle('display', 'inline-block');
        });
    });
});

window.addEvent('load', function () {
    // Center the toplist images.
    var toplist_entries = jQuery(".toplist-entry-outer");
    for (var i=0; i < toplist_entries.length; i++) {
        var toplist_entry = jQuery(toplist_entries[i]);
        var image = toplist_entry.find("img");

        if (toplist_entry.css("display") == "none") {
            toplist_entry.css("display", "inline-block");
            setImagePosition(image);
            toplist_entry.css("display", "none");
        } else {
    	   setImagePosition(image);
        }
    }
});

function setImagePosition(image) {
    jQuery(image).css("margin-top", -1 * image.height()/2);
    jQuery(image).css("margin-left", -1 * image.width()/2);
}
