$(function() {
  $('.nooklyn_listings_index_container, .listing-show-details').on('click', '.like-button', function(e) {
    var elementId = '#' + ($(this).parents('.nooklyn_listing_square').attr('id') || $(this).parents('.listing-like').attr('id'));
    var target = this;

    var listingId = parseInt(elementId.split('_').pop());

    $.get('/listings/' + listingId + '/unlike').done(function() {
      $(target).removeClass('like-button').addClass('unlike-button');
      $(target).parents('.listing-like').find('h6').text('Save');
      $('.unlike-notice', elementId).fadeIn().delay(1000 * 5).fadeOut();
    });

    return false;
  });

  $('.nooklyn_listings_index_container, .listing-show-details').on('click', '.unlike-button', function(e) {
    var elementId = '#' + ($(this).parents('.nooklyn_listing_square').attr('id') || $(this).parents('.listing-like').attr('id'));
    var target = this;

    var listingId = parseInt(elementId.split('_').pop());

    $.ajax('/listings/' + listingId + '/like', {
      contentType: 'application/json',
      dataType: 'json'
    }).done(function() {
      $(target).removeClass('unlike-button').addClass('like-button');
      $(target).parents('.listing-like').find('h6').text('Saved');
      $('.like-notice', elementId).fadeIn().delay(1000 * 5).fadeOut();
    }).fail(function(jqxhr, textStatus, error) {
      if (jqxhr.status == 401) {
        window.location.href = "/login";
      } else {
        $('.error-notice', elementId).fadeIn().delay(1000 * 5).fadeOut();
      }
    });

    return false;
  });
});
