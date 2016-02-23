var markers = {};
var currentMarker;

var likedListingIds;

function listingsInitialize() {
  var mapDiv = document.getElementById('nooklyn_listings_index_map');
  if ($(mapDiv).length < 1) {
    return;
  }

  var centerLatitude, centerLongitude;
  centerLatitude = $(mapDiv).data("latitude");
  centerLongitude = $(mapDiv).data("longitude");

  var nooklynCenter = new google.maps.LatLng(centerLatitude, centerLongitude)
  var mapOptions = {
    zoom: $(mapDiv).data("zoom"),
    center: nooklynCenter,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false,
    styles: mapStyles
  };
  var map = new google.maps.Map(mapDiv, mapOptions);

  // show public transit instead of highway information
  var transitLayer = new google.maps.TransitLayer();
  transitLayer.setMap(map);

  // clear selection on map click
  map.addListener('click', function() {
    clearSelection();
  });

  $.ajax({
    url: "/listings-partial",
    cache: false,
    success: function(html) {
      $('.nooklyn_listings_index_container').append(html);

      $(".nklyn-listing").each(function() {
        var listingId = $(this).data('id');
        var listingLatitude = $(this).data("latitude");
        var listingLongitude = $(this).data("longitude");
        var listingPhoto = $(this).data("photo");
        var listingFormattedprice = $(this).data("price");
        var listingFormattedbedrooms = $(this).data("bedrooms");
        var listingFormattedbathrooms = $(this).data("bathrooms");

        // marker
        var marker = new google.maps.Marker({
          position: new google.maps.LatLng(listingLatitude, listingLongitude),
          icon: redMapMarker,
          map: map
        });
        marker.set('id', listingId);
        markers[listingId] = marker;
        $(this).data('marker', marker);

        // marker click
        marker.addListener('click', function() {
          var listingId = this.get('id');
          updateSelection(listingId);
        });
      });

      // listing card mouseover/mouseout
      $('.nooklyn_listing_square')
        .on('mouseover', function() {
          var listingId = $(this).data('id');
          updateSelection(listingId, false);
        })
        .on('mouseout', function() {
          clearSelection();
        });

      // post load
      postLoad();
    }
  });

  function clearSelection() {
    // clear marker
    if (typeof(currentMarker) !== 'undefined') {
      currentMarker.setIcon(redMapMarker);
      currentMarker.setZIndex(1);
    }

    // clear listing card
    $('div.nooklyn_listing_square').removeClass('selected');
  }

  function updateSelection(listingId, scrollToCard) {
    if (typeof(scrollToCard) === 'undefined') {
      scrollToCard = true;
    }

    var selectedListingCard = $("#listing_card_" + listingId);

    // if already selected, click through to listing detail view
    var alreadySelected = selectedListingCard.hasClass('selected');
    if (alreadySelected) {
      var selectedListingLink = selectedListingCard.find('a').attr('href');
      window.location = selectedListingLink;
      return;
    }

    // clear selection
    clearSelection();

    // select marker
    var marker = markers[listingId];
    marker.setIcon(blackMapMarker);
    marker.setZIndex(99999);
    currentMarker = marker;

    // select card
    selectedListingCard.addClass('selected');

    // scroll to selected card
    if (scrollToCard) {
      $('.nooklyn_listings_index_container').animate({
          scrollTop: selectedListingCard.get(0).offsetTop - parseInt(selectedListingCard.css('marginBottom'))
      }, 0);
    }
  }

  $(".nooklyn_listings_index_container").on("filterListings", ".nklyn-listing", function(event, filterInfo){
    var listingZoningType, listingBedrooms;
    function findListingZoningType(listing) {
      var isResidential = $(listing).attr('data-residential')
      if (isResidential === "true") {
        listingZoningType = "Residential";
      }
      else if (isResidential === "false") {
        listingZoningType = "Commercial";
      }
      else {
        listingZoningType = "None";
      }
    }

    function hideListing(listing) {
      $(listing).hide();
      if (($(listing).data('marker') !== null && $(listing).data('marker') !== undefined)) {
        return $(listing).data('marker').setVisible(false);
      }
    }

    function showListing(listing) {
      $(listing).show();
      if (($(listing).data('marker') !== null && $(listing).data('marker') !== undefined)) {
        return $(listing).data('marker').setVisible(true);
      }
    }

    findListingZoningType(this);
    listingBedrooms = parseFloat($(this).attr('data-bedrooms'));
    listingBedrooms = (listingBedrooms > 5 ? 5 : listingBedrooms);

    // If there is a Zoning filter turned on and the listing does not match it, hide the listing.
    if (filterInfo.zoningType !== "None" && listingZoningType != filterInfo.zoningType) {
      hideListing(this);
    }
    // If there is a bedroom filter turned on and the listing does not match it, hide the listing.
    else if (filterInfo.bedrooms.length > 0 && filterInfo.bedrooms.indexOf(parseFloat(listingBedrooms)) === -1) {
      hideListing(this);
    }
    // If the minimum price filter is turned on and the listing price is less than the filter price, hide the listing.
    else if (typeof(filterInfo.price.min) === "number" && filterInfo.price.min > $(this).data('price')) {
      hideListing(this);
    }
    // If the maximum price filter is turned on and the listing price is more than the filter price, hide the listing.
    else if (typeof(filterInfo.price.max) === "number" && filterInfo.price.max < $(this).data('price')) {
      hideListing(this);
    }
    else {
      showListing(this);
    }
  });

  function getMinPriceFilter(){
    return parseFloat($('#minimum-price').val().replace(/,/g, ''));
  }
  function getMaxPriceFilter(){
    return parseFloat($('#maximum-price').val().replace(/,/g, ''));
  }

  function bedroomFilters() {
    var bedrooms = [];
    // Store all of the bedroom filters
    var bedroomFilterBar = $('#bedroom-filter-bar').children();
    // Iterate over each bedroom filter and check if it is active
    for (var i=0; i<bedroomFilterBar.length; i++) {
      var bedroomFilter = $(bedroomFilterBar[i]);
      // If the bedroom filter is active, push its value and its value plus 0.5 into the bedrooms array. This will allow half bedrooms to show up in the search (ie, when the "1" bedroom filter is selected, listings with 1.5 bedrooms will also display).
      if ($(bedroomFilter).hasClass('active')) {
        var bedroomFilterValue = parseFloat($(bedroomFilter).val());
        bedrooms.push(bedroomFilterValue);
        bedrooms.push(bedroomFilterValue + 0.5);
      }
    }
    return bedrooms;
  }

  function findFilterZoningType() {
    var zoningType = $('#zoning-types').find('.active').html();
    if (zoningType !== "Residential" && zoningType !== "Commercial") {
      zoningType = "None";
    }
    return zoningType;
  }

  function createFilterListingsTrigger() {
    $('.nklyn-listing').trigger('filterListings', [{bedrooms: bedroomFilters(), price: {min: getMinPriceFilter(), max: getMaxPriceFilter()}, zoningType: findFilterZoningType()}]);
  }

  // filter on toggling residential/commercial, price
  $('.filter').on('click', function() {
    // residential/commercial radio button
    if ($(this).attr('data-filter-type') === "residential") {
      $('*[data-filter-type="residential"]').removeClass('active');
      $(this).addClass('active');
    } else { // price button
      $(this).toggleClass('active');
    }
    createFilterListingsTrigger();
  });

  // Trigger custom listener whenever a price is entered into min/max filter.
  $('.price').on('keyup', function(){
    createFilterListingsTrigger();
  });

  function postLoad() {
    // initially restrict to commercial for /commercial, residential otherwise
    if (window.location.pathname.indexOf('commercial') !== -1) {
      $('#commercial-button').addClass('active');
    } else {
      $('#residential-button').addClass('active');
    }
    createFilterListingsTrigger();

    // liked listings
    likedListingIds.forEach(function(listingId) {
      var button = $("#listing_card_" + listingId).find('a.unlike-button')
      button.removeClass('unlike-button');
      button.addClass('like-button');
    });
  }
}

google.maps.event.addDomListener(window, 'load', listingsInitialize);
