$(function() {
  $("#nklyn-table-filter").focus();
  $("#nklyn-table-filter").on('keyup change', function() {
    $("tr.table-row").each(function() {
      var orgName, orgSearch;

      orgSearch = $('#nklyn-table-filter').val().toLowerCase() ? $('#nklyn-table-filter').val().toLowerCase() : "";
      orgName = $(this).data("name").toString().toLowerCase();

      if (orgName.match(orgSearch)) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  });
});