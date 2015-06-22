$(function(){
    $('#id_contacts').multiSelect({
        'afterSelect': function(i) {
            var invitees = $('.ms-selection li').size();
            $('.invitees-count').text(invitees);
        },
        'afterDeselect': function(i) {
            var invitees = $('.ms-selection li').size();
            $('.invitees-count').text(invitees);
        }
    });
    var contacts = $('.ms-list li');
    $('.contacts-count').text(contacts.size());

    $('#select-all').bind('click',function() {
        $('#id_contacts').multiSelect('select_all');
    });

    $('#deselect-all').bind('click',function() {
        $('#id_contacts').multiSelect('deselect_all');
    });
});
