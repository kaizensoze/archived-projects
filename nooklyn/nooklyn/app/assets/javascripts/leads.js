$(function() {
  $(".datepicker").pickadate({
    format: 'dddd mmm dd, yyyy',
    min: true
  });
});

$(function() {
  $(".matrix_date").pickadate({
    format: 'mm/dd/yy'
  });
});

$(function() {
  $(".timepicker").pickatime({
    format: 'h:i a',
    formatLabel: '<b>h</b>:i <!i>a</!i>',
    min: [10,0],
    max: [20,0]
  });
});
