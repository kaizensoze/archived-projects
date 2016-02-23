function roomsmap() {
  var mapDiv = document.getElementById('rooms-map');
  if ($(mapDiv).length < 1) {
    return;
  }

  // enable the visual refresh
  google.maps.visualRefresh = true;

  var centerLatitude, centerLongitude;
  centerLatitude = $(mapDiv).data("latitude");
  centerLongitude = $(mapDiv).data("longitude");

  var markers;
  var nooklynCenter = new google.maps.LatLng(centerLatitude, centerLongitude);
  var mapOptions = {
    zoom: 13,
    center: nooklynCenter,
    scrollwheel: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false,
    styles: mapStyles
  };
  var map = new google.maps.Map(mapDiv, mapOptions);

  // show public transit instead of highway information
  var transitLayer = new google.maps.TransitLayer();
  transitLayer.setMap(map);

  var markers = [];
  var infoWindows = [];
  var markerToInfoWindow = {};

  // dismiss open info window on map click
  map.addListener('click', function() {
    closeInfoWindows(infoWindows);
  });

  $(".roommate_card").each(function() {
    var listingId, listingLatitude, listingLongitude, listingPhoto, listingInfowindow, listingFormattedprice;
    listingId = $(this).data('id');
    listingLatitude = $(this).data("latitude");
    listingLongitude = $(this).data("longitude");
    listingPhoto = $(this).data("photo");
    listingFormattedprice = $(this).data("formatted-price");

    // marker
    var marker = new google.maps.Marker({
      position: new google.maps.LatLng(listingLatitude, listingLongitude),
      icon: redMapMarker,
      map: map
    });
    marker.set('id', listingId);
    markers.push(marker);
    $(this).data('marker', marker);

    marker.addListener('click', function() {
      // close any open info windows
      closeInfoWindows(infoWindows);

      // open marker's info window
      var infoWindow = markerToInfoWindow[this.get('id')];
      infoWindow.open(map, this);
    });

    // info window
    var contentString = '<div class="listing-info-window">'
                      + '  <a class="listing-map-overlay" href="/room_posts/' + listingId + '">'
                      + '    <img class="img-small" src="' + listingPhoto + '">'
                      + '  </a>'
                      + '  <h3 class="listing-maps-price">' + listingFormattedprice + '</h3>'
                      + '</div>';
    var infoWindow = new google.maps.InfoWindow({
      content: contentString,
      maxWidth: 250
    });
    infoWindows.push(infoWindow);
    markerToInfoWindow[marker.get('id')] = infoWindow;
  });
}

google.maps.event.addDomListener(window, 'load', roomsmap);
