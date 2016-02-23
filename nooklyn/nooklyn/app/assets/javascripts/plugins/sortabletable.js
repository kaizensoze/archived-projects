$(function() {
  $('table.nklyn-table').on('click', 'th', function(e) {
    var allHeaders = $(this).parent().children();
    var table = $(this).parents('table')
    var index = allHeaders.index($(this));

    if ( parseInt(table.attr('sorted-index')) === index ) {
      var tbody = table.children('tbody');
      tbody.html(tbody.children().get().reverse());
      return;
    }

    parseNumber = function(number_string) {
      if (number_string.indexOf('.') >= 0)
        return parseFloat(number_string);
      else
        return parseInt(number_string);
    }

    sorted_rows = table.find('tbody tr').sort(function(a, b) {
      var columnA = $(a).children()[index], columnB = $(b).children()[index];

      if ($(columnA).attr('numerical-value')) {
        var columnANum = parseNumber($(columnA).attr('numerical-value'));
        var columnBNum = parseNumber($(columnB).attr('numerical-value'));

        if (columnANum < columnBNum) return -1;
        if (columnANum > columnBNum) return 1;
        return 0;
      } else {
        var columnAValue = $(columnA).text()
        var columnBValue = $(columnB).text()
        return columnAValue.localeCompare(columnBValue)
      }
    });
    table.children('tbody').html(sorted_rows);
    table.attr('sorted-index', index);
  });
});
