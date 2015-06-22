function toggle_opentable_widget() {
  jQuery('#OT_form').toggle();
}
jQuery(document).ready(function($) {
  // Enable toggling widget
  $('#show-opentable-widget').click(function(evt) {
    evt.preventDefault();
    toggle_opentable_widget();
  });
  $('#OT_form').attr('target', '_blank');
});