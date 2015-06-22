$(function(){
  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };

  // subjects
  $('.who-to-call-subjects-table > tbody').sortable({
    helper: fixHelper,
    stop: function(event, ui) {
      var newSortOrder = {};

      // update sort order on client side
      $('.who-to-call-subjects-table > tbody tr').each(function(idx, row) {
        var newIndex = idx + 1;
        newSortOrder[$(row).data('id')] = newIndex;
        // $(row).find('td:nth-child(2)').html(newIndex);
      });

      // update sort order on server end
      $.post('/cms/who_to_call_subjects/sort', {'new_sort_order': newSortOrder}, function(data) {
        // console.log(data);
      });
    }
  });

  // items
  $('.who-to-call-items-table > tbody').sortable({
    helper: fixHelper,
    stop: function(event, ui) {
      var newSortOrder = {};

      // update sort order on client side
      $('.who-to-call-items-table > tbody tr').each(function(idx, row) {
        var newIndex = idx + 1;
        newSortOrder[$(row).data('id')] = newIndex;
        // $(row).find('td:nth-child(2)').html(newIndex);
      });

      var subjectId = $('input#who-to-call-subject-id').val();

      // update sort order on server end
      $.post('/cms/who_to_call_subjects/' + subjectId + '/who_to_call_items/sort', {'new_sort_order': newSortOrder}, function(data) {
        // console.log(data);
      });
    }
  });
})