$(function() {
  // filter inputs
  $(".deposit-filter").on('keyup change', dfilter);
});

function dfilter() {
  var rows = $("tr.deposit-row");
  rows.hide();

  // address
  var addressVal = $.trim($("#address-search").val());
  if (addressVal.length > 0) {
    var address = addressVal.toLowerCase();
    rows = rows.filter(function(i, v) {
      var rowAddress = $(this).data("address").toString().toLowerCase();
      return rowAddress.match(address);
    });
  }

  // agent
  var agentVal = $("#agent-input").val();
  if (agentVal.length > 0) {
    var agent = agentVal;
    rows = rows.filter(function(i, v) {
      var listingAgent = $(this).data("listing-agent");
      var salesAgent = $(this).data("sales-agent");
      var splitAgent = $(this).data("split-agent");
      return listingAgent === agent || salesAgent === agent || splitAgent === agent;
    });
  }

  rows.show();
}

$(function() {
  var updateStatus;
  $(".edit_deposit input[name='deposit[deposit_status_id]']").on("change", function() {
    var status;
    status = $(this).val();
    return updateStatus($(this), status);
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
    $(".edit_deposit input").prop("disabled", true);
    $input.parent().append(" <i class='nklyn-icon-clock'></i>");
    return $.ajax(postUrl, {
      type: 'POST',
      dataType: 'json',
      data: data
    }).done(function() {
      $(".edit_deposit input").prop("disabled", false);
      return setTimeout((function() {
        $(".nklyn-icons-clock").remove();
        return $input.parent().append(" <i class='nklyn-icon-dot-fill nklyn-green'></i>");
      }), 150);
    }).fail(function() {
      return setTimeout((function() {
        $(".nklyn-icons-clock").remove();
        $input.parent().append(" <i class='nklyn-icon-frown'></i>");
        return alert("There was a problem updating the deposit. Refresh the page and try again.");
      }), 150);
    });
  };
});


