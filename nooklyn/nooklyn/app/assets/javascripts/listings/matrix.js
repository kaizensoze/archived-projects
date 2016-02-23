$(function() {
  // filter inputs
  $(".matrix-listing-filter").on('keyup change', filter);

  // toggle buttons
  $("#bedroom-filter > button, #bathroom-filter > button, #residential-filter, #commercial-filter, #owner-filter, #pets-filter, #owner-pays-filter, #exclusive-filter").on('click', function() {
    // manually add/remove active class to button just clicked
    if ($(this).hasClass('active')) {
      $(this).removeClass('active');
    } else {
      $(this).addClass('active');
    }
    filter();
  });

  // neighborhood list
  $(".neighborhood-filter li").on('click', function(evt) {
    evt.preventDefault();

    if ($(this).hasClass('active') && $(this).text() !== 'All Listings') {
      $(this).removeClass('active');

      if ($(".neighborhood-filter li.active").length === 0) {
        $(".neighborhood-filter li").first().addClass('active');
      }
    } else {
      $(this).addClass('active');

      if ($(this).text() !== 'All Listings') {
        $(".neighborhood-filter li").first().removeClass('active');
      } else {
        $(".neighborhood-filter li").removeClass('active');
        $(this).addClass('active');
      }
    }

    filter();
  });
});

function filter() {
  var rows = $("tr.matrix-listing");
  rows.hide();

  // neighborhood
  var selectedNeighborhoods = [];
  $(".neighborhood-filter li.active a").map(function() {
    var aText = $(this).text();
    if (aText !== "") {
      selectedNeighborhoods.push(aText);
    }
  });
  if (selectedNeighborhoods.indexOf("All Listings") === -1) {
    rows = rows.filter(function(i, v) {
      var rowNeighborhood = $(this).data("neighborhood");
      return selectedNeighborhoods.indexOf(rowNeighborhood) !== -1;
    });
  }

  // listing id
  var listingIdVal = $.trim($("#listing-id").val());
  if (listingIdVal.length > 0) {
    var listingId = parseFloat(listingIdVal);
    rows = rows.filter(function(i, v) {
      var rowListingId = $(this).data("id");
      return rowListingId === listingId;
    });
    // exclusive filter so short-circuit
    rows.show()
    return;
  }

  // address
  var addressVal = $.trim($("#address-search").val());
  if (addressVal.length > 0) {
    var address = addressVal.toLowerCase();
    rows = rows.filter(function(i, v) {
      var rowAddress = $(this).data("address").toString().toLowerCase();
      return rowAddress.match(address);
    });
  }

  // date available
  var dateAvailableVal = $.trim($("#move_in_search").val());
  if (dateAvailableVal.length > 0) {
    var dateAvailableParts = dateAvailableVal.split('/');
    var dateAvailable = dateAvailableParts[2] + '/' + dateAvailableParts[0] + '/' + dateAvailableParts[1];  // change to yy/mm/dd
    rows = rows.filter(function(i, v) {
      var rowDateAvailableRaw = $(this).data("move");
      if (typeof(rowDateAvailableRaw) !== "undefined") {
        var rowDateAvailableParts = rowDateAvailableRaw.split('/');
        var rowDateAvailable = rowDateAvailableParts[2] + '/' + rowDateAvailableParts[0] + '/' + rowDateAvailableParts[1];
        return rowDateAvailable >= dateAvailable;
      }
      return false;
    });
  }

  // min price
  var minPriceVal = $.trim($("#minimum-price").val().replace(/,/g, ''));
  if (minPriceVal.length > 0) {
    var minPrice = parseFloat(minPriceVal);
    rows = rows.filter(function(i, v) {
      var rowPrice = $(this).data("price");
      return rowPrice >= minPrice;
    });
  }

  // max price
  var maxPriceVal = $.trim($("#maximum-price").val().replace(/,/g, ''));
  if (maxPriceVal.length > 0) {
    var maxPrice = parseFloat(maxPriceVal);
    rows = rows.filter(function(i, v) {
      var rowPrice = $(this).data("price");
      return rowPrice <= maxPrice;
    });
  }

  // beds
  var bedVals = $("#bedroom-filter").children().filter(function(i, v) {
    return $(this).hasClass('active');
  }).map(function() {
    return parseFloat($(this).val());
  }).get();
  if (bedVals.length > 0) {
    rows = rows.filter(function(i, v) {
      var rowBeds = Math.floor($(this).data("bedrooms"));
      if (bedVals.indexOf(5.0) !== -1) {
        return bedVals.indexOf(rowBeds) != -1 || rowBeds >= 5.0;
      }
      return bedVals.indexOf(rowBeds) != -1;
    });
  }

  // baths
  var bathVals = $("#bathroom-filter").children().filter(function(i, v) {
    return $(this).hasClass('active');
  }).map(function() {
    return parseFloat($(this).val());
  }).get();
  if (bathVals.length > 0) {
    rows = rows.filter(function(i, v) {
      var rowBaths = Math.floor($(this).data("bathrooms"));
      if (bathVals.indexOf(5.0) !== -1) {
        return bathVals.indexOf(rowBaths) != -1 || rowBaths >= 5.0;
      }
      return bathVals.indexOf(rowBaths) != -1;
    });
  }

  // amenity
  var amenityVal = $("#select-amenities").val();
  if (amenityVal.length > 0) {
    var amenity = amenityVal;
    rows = rows.filter(function(i, v) {
      var rowAmenities = $(this).data("amenities").toString();
      return rowAmenities.match(amenity);
    });
  }

  // agent
  var agentVal = $("#agent").val();
  if (agentVal.length > 0) {
    var agent = agentVal;
    rows = rows.filter(function(i, v) {
      var listingAgent = $(this).data("listing-agent");
      var salesAgent = $(this).data("sales-agent");
      return listingAgent === agent || salesAgent === agent;
    });
  }

  // residential
  var residential = $('#residential-filter').hasClass('active');
  if (residential) {
    rows = rows.filter(function(i, v) {
      var rowIsResidential = $(this).data("is-residential");
      return rowIsResidential === true;
    });
  }

  // commercial
  var commercial = $('#commercial-filter').hasClass('active');
  if (commercial) {
    rows = rows.filter(function(i, v) {
      var rowIsResidential = $(this).data("is-residential");
      return rowIsResidential === false;
    });
  }

  // pets
  var petsAllowed = $('#pets-filter').hasClass('active');
  if (petsAllowed) {
    rows = rows.filter(function(i, v) {
      var rowPetsAllowed = $(this).data("pets");
      return rowPetsAllowed === true;
    });
  }

  // owner pays
  var ownerPays = $('#owner-pays-filter').hasClass('active');
  if (ownerPays) {
    rows = rows.filter(function(i, v) {
      var rowOwnerPays = parseFloat($(this).data("owner-pays"));
      return rowOwnerPays > 0.0;
    });
  }

  // exclusive
  var exclusive = $('#exclusive-filter').hasClass('active');
  if (exclusive) {
    rows = rows.filter(function(i, v) {
      var rowExclusive = $(this).data("exclusive");
      return rowExclusive === true;
    });
  }

  rows.show();
}
