$(function(){
  $('.background-image-container').sortable({
    stop: function(event, ui) {
      var newSortOrder = {};

      // update sort order on client side
      $('.background-image-container > div').each(function(idx, div) {
        var newIndex = idx + 1;
        newSortOrder[$(div).data('id')] = newIndex;
      });

      // update sort order on server end
      $.post('/cms/background_images/sort', {'new_sort_order': newSortOrder}, function(data) {
        // console.log(data);
      });
    }
  });
})