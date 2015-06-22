$(function(){
  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };

  $('.announcements-table > tbody').sortable({
    helper: fixHelper,
    stop: function(event, ui) {
      var newSortOrder = {};

      // update sort order on client side
      $('.announcements-table > tbody tr').each(function(idx, row) {
        var newIndex = idx + 1;
        newSortOrder[$(row).data('id')] = newIndex;
        // $(row).find('td:nth-child(2)').html(newIndex);
      });

      // update sort order on server end
      $.post('/cms/announcements/sort', {'new_sort_order': newSortOrder}, function(data) {
        // console.log(data);
      });
    }
  });
})