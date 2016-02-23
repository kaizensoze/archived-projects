// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .


// Limit text areas to 250 characters
$(function() {
  var maxchars = 250;

  // enable/disable send button
  $('.limit_250').each(function() { enableDisableSendButton(this); });

  $('.limit_250').keyup(function () {
      var tlength = $(this).val().length;
      $(this).val($(this).val().substring(0, maxchars));
      var tlength = $(this).val().length;
      remain = maxchars - parseInt(tlength);
      $('#remain').text(remain);

      // enable/disable send button
      enableDisableSendButton(this);
  });
});

// Limit text areas to 500 characters
$(function() {
  var maxchars = 500;

  // enable/disable send button
  $('.limit_500').each(function() { enableDisableSendButton(this); });

  $('.limit_500').keyup(function () {
    var tlength = $(this).val().length;
    $(this).val($(this).val().substring(0));
    var tlength = $(this).val().length;
    remain = maxchars - parseInt(tlength);
    $('#remain').text(remain);

    // enable/disable send button
    enableDisableSendButton(this);
  });
});

// Enable/disable send button based on form input's content
function enableDisableSendButton(input) {
  var inputText = $(input).val();

  var disabled = false;
  if (inputText.trim().length == 0) {
    disabled = true;
  }

  var submitButton = $(input).closest('form').find(':submit');
  submitButton.toggleClass('disabled', disabled);
  $(submitButton).prop('disabled', disabled);
}

$(function() {
  $(".selectize").selectize({});
});

$(function() {
  $(".input-tags").selectize({});
});
