$(function(){
  on_page_load();
})

function on_page_load() {
  $('.datepicker').datepicker({
    minDate: 0,
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd"
  });
  
  $('.datetimepicker').datetimepicker({
    minDate: 0,
    changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd",
    timeFormat: "HH:mm:00",
    showButtonPanel: false
  });
}

function ajax_load_select2(url, selector, container, add, multiple) { 
  $.get(url, function(data) {
    var results = { results: data };
    $(selector).select2({
      width: "100%",
      data: data,
      multiple: multiple,
      createSearchChoice: function(term, data) { 
        if(add) {
          if ($(data).filter(function() { 
            return this.text.toLowerCase().match("^" + term.toLowerCase());
          }).length===0) {
            return {id:term, text:term};  
          }  
        } else {
          return null;
        }
      }
    });
    $(container).removeClass("loading").addClass("loaded");  
  });
}