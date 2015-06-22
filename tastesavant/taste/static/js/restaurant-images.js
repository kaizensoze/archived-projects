
window.addEvent('domready', function () {

    $$('.image-nav-button').addEvent('click', function (evt) {
        var img_src = evt.target.src;
        var direction;  // 0 = left, 1 = right

        if (String.from(img_src).test('left')) {
            direction = "left";
        } else {
            direction = "right";
        }

        // Figure out which image is currently shown.
        var images = $('image-container').getElements('img');
        var credits = $('image-carousel').getElements('.image-credits');
        var dots = $('image-nav').getElements('div');
        var current = dots.indexOf($('image-nav').getElement('.active'));

        // Determine which image to show next.
        var num_dots = dots.length;
        var next;
        if (direction == "left") {
            if (current == 0) {
                return;
            }
            next = current - 1;
        } else {
            if (current == num_dots - 1) {
                return;
            }
            next = current + 1;
        }

        dots[current].removeClass("active");
        dots[next].addClass("active");

        setImagePosition(jQuery(images[next]));

        images[next].setStyle('display', 'block');
        images[current].setStyle('display', 'none');

        credits[next].setStyle('display', 'block');
        credits[current].setStyle('display', 'none');
    });
});

window.addEvent('load', function () {

    // Center the initial image.
    var images = jQuery("#image-container img");
    var image = jQuery(images[0]);

    setImagePosition(image);

    jQuery("#image-carousel").css("visibility", "visible");
});

function setImagePosition(image) {
  jQuery(image).css("margin-top", -1 * image.height()/2);
  jQuery(image).css("margin-left", -1 * image.width()/2);
}

jQuery(document).ready(function ($) {
  // link to show blackbook modal
  $('.blackbook').click(function (evt) {
    evt.preventDefault();
    $('#blackbook-modal').show();
    setBlackbookSelect();
  });

  // clicking anywhere on blackbook modal closes blackbook dropdown
  $('#blackbook-modal').click(function (evt) {
    var className = $(evt.target).attr('class');

    if (className === "select-blackbook" || className === "blackbook-list-item") {
    } else {
      $('#blackbook-modal .blackbook-list').hide();
    }
  });

  // close blackbook modal
  $('#blackbook-modal .close').click(function () {
    $('#blackbook-modal').hide();
  });

  // click blackbook select input to show blackbook dropdown items
  $('#blackbook-modal .select-blackbook').click(function (evt) {
    $('#blackbook-modal .blackbook-list').show();
  });

  // select blackbook dropdown item
  $('#blackbook-modal .blackbook-list li').live('click', function (evt) {
    setBlackbookSelect($(evt.target));
    $('#blackbook-modal .blackbook-list').hide();
  });

  function setBlackbookSelect(blackbookItem) {
    var _blackbookItem;

    if (typeof blackbookItem === 'undefined') {
      var firstBlackbookItem = $('#blackbook-modal .blackbook-list li').first();
      _blackbookItem = firstBlackbookItem;
    } else {
      _blackbookItem = blackbookItem;
    }

    var selectInput = $('#blackbook-modal .select-blackbook');
    var hiddenInput = $('#blackbook-modal .selected-blackbook-item');

    selectInput.val(_blackbookItem.text());
    hiddenInput.val(_blackbookItem.val());

    // hide create blackbook form if necessary
    if (_blackbookItem.attr('class') === "new-blackbook-item") {
      $('#blackbook-modal #add-new-list').show().focus();
      $('#blackbook-modal .create-blackbook').val('').focus();
    } else {
      $('#blackbook-modal #add-new-list').hide();
    }
  }

  $("#add-new-list").submit(function (evt) {
    evt.preventDefault();

    var newListName = $('#add-new-list input[type=text]').val();

    if (newListName !== '') {
      $.ajax('/api/1/blackbook/', {
        type: 'POST',
        data: {
          title: newListName
        },
        success: function (data) {
          var newBlackbookItem = $('<li value="'+data.id+'" class=blackbook-list-item>'+data.title+'</li>');

          // add new blackbook item and select it
          $('#blackbook-modal .blackbook-list li:last-child').before(newBlackbookItem);
          setBlackbookSelect(newBlackbookItem);
        },
        error: function () {}
      });
    }
  });

  $('#blackbook-modal .add-to-blackbook').click(function (evt) {
    evt.preventDefault();

    var listId = $('#blackbook-modal .selected-blackbook-item').val();

    var restaurantApiURI = $('#restaurant_api_uri').val();

    $.ajax('/api/1/blackbook/' + listId + '/entries/', {
      type: 'POST',
      data: {
        entry: 'Added from restaurant page',
        restaurant: restaurantApiURI
      },
      success: function (data) {
      },
      error: function () {
      },
      complete: function () {
        $('#blackbook-modal').hide();
      }
    });
  });
});
