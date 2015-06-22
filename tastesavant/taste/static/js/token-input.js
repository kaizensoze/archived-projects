jQuery.noConflict();
jQuery("#id_recipient").tokenInput('/messages/lookup/', {
    propertyToSearch: "user",
    tokenValue: 'user',
    hintText: 'Begin typing your contact\'s name..',
    tokenFormatter: function(item) {
        return "<li><p>" + item.first_name + " " + item.last_name + "</p></li>";
    },
    resultsFormatter: function(item){
        return "<li><span class='avatar-30x30-frame'><img src='" + item.url + "' alt='" + item.user + "' />" + 
            "</span><span class='search-name'>" + item.first_name + " " + item.last_name + "</span></li>"
    }
});

jQuery('.reply-to-message').live('click',function() {
    if(jQuery("#id_recipient").hasClass('is-reply')) {
        var user = jQuery('#reply-sender-id').val();
        var first = jQuery('#reply-sender-firstname').val(); 
        var last = jQuery('#reply-sender-lastname').val(); 
        var msg_id = jQuery('#reply-message-id').val(); 
        jQuery("#id_recipient").tokenInput("add", {user: user, first_name: first, last_name: last});
        var form = jQuery('#message-container').children('form');
        form.attr("action", "/messages/reply/" + msg_id + "/");
    }
});

jQuery(".close-button").bind('click', function() {
    var message = jQuery(this).parent().siblings('#message-container').children('form');
    message.find(':input').each(function() {
        switch(this.type) {
        case 'text':
            this.value ='';
        case 'textarea':
            this.value ='';
        }
        jQuery("#id_recipient").removeClass('is-reply');
        jQuery("#id_recipient").tokenInput("clear");
    });

});

jQuery('ul.token-input-list').bind('click',function() {
    jQuery(this).css('background', '#FFF');
});

jQuery('#FormCompose').submit(function(){
    jQuery('button.send').attr('disabled', 'disabled');
});
