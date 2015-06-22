$(function(){
  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };

  // subjects
  $('.did-you-know-subjects-table > tbody').sortable({
    helper: fixHelper,
    stop: function(event, ui) {
      var newSortOrder = {};

      // update sort order on client side
      $('.did-you-know-subjects-table > tbody tr').each(function(idx, row) {
        var newIndex = idx + 1;
        newSortOrder[$(row).data('id')] = newIndex;
        // $(row).find('td:nth-child(2)').html(newIndex);
      });

      // update sort order on server end
      $.post('/cms/did_you_know_subjects/sort', {'new_sort_order': newSortOrder}, function(data) {
        // console.log(data);
      });
    }
  });

  // items
  $('.did-you-know-items-table > tbody').sortable({
    helper: fixHelper,
    stop: function(event, ui) {
      var newSortOrder = {};

      // update sort order on client side
      $('.did-you-know-items-table > tbody tr').each(function(idx, row) {
        var newIndex = idx + 1;
        newSortOrder[$(row).data('id')] = newIndex;
        // $(row).find('td:nth-child(2)').html(newIndex);
      });

      var subjectId = $('input#did-you-know-subject-id').val();

      // update sort order on server end
      $.post('/cms/did_you_know_subjects/' + subjectId + '/did_you_know_items/sort', {'new_sort_order': newSortOrder}, function(data) {
        // console.log(data);
      });
    }
  });
})