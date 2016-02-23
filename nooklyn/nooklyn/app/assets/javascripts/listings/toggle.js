$(function() {
    $(".btn-group").each(function() {
      var input;
      input = $(this).children('input');
      return $(this).children('.btn').each(function() {
        return $(this).on('click', function() {
          return input.val($(this).attr('value')).change();
        });
      });
    });
});