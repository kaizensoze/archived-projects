$(function() {
  $(".edit_listing input[name='listing[action_status]']").on("change", function() {
    var status = $(this).val();
    var listingId = $(this).parents('form').siblings('#listing_id').val();
    var _this = $(this)

    $(".icon-ok-sign").remove();
    $(".edit_listing input").prop("disabled", true);
    _this.after("<i class='nklyn-icon-clock'></i>");

    $.ajax({
      type: "POST",
      url: "/matrix/listings/" + listingId + "/change_status",
      data: {
        "status": status
      },
      dataType: 'json'
    }).done(function() {
      $(".edit_listing input").prop("disabled", false);
      return setTimeout(function() {
        $(".nklyn-icon-clock").remove();
        return _this.parent().append("<i class='nklyn-icon-dot-fill nklyn-green'></i>");
      }, 150);

    }).fail(function() {
      return setTimeout((function() {
        $(".nklyn-icon-clock").remove();
        _this.parent().append("<i class='nklyn-icon-face-sad'></i>");
      }), 150);
    });


  });
});

$(function() {
  var updateStatus;
  $(".edit_listing input[name='listing[featured]']").on("change", function() {
    var featured;
    featured = $(this).prop("checked");
    return updateStatus($(this), featured);
  });
  return updateStatus = function($input, value) {
    var data, field, postUrl;
    $input.prop("disabled", true);
    field = $input.attr('name');
    data = {
      '_method': 'put'
    };
    data[field] = value;
    postUrl = $input.parents("form").attr("action");
    $(".icon-ok-sign").remove();
    $(".edit_listing input").prop("disabled", true);
    $input.parent().append(" <i class='nklyn-icon-clock'></i>");
    return $.ajax(postUrl, {
      type: 'POST',
      dataType: 'json',
      data: data
    }).done(function() {
      $(".edit_listing input").prop("disabled", false);
      return setTimeout((function() {
        $(".nklyn-icons-clock").remove();
        return $input.parent().append(" <i class='nklyn-icon-dot-fill nklyn-green'></i>");
      }), 150);
    }).fail(function() {
      return setTimeout((function() {
        $(".nklyn-icons-clock").remove();
        $input.parent().append(" <i class='nklyn-icon-frown'></i>");
        return alert("There was a problem updating the listing. Refresh the page and try again.");
      }), 150);
    });
  };
});

