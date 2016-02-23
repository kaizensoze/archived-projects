function listingInitialize() {
  var mapDiv = document.getElementById('listings-show-map');
  if ($(mapDiv).length < 1) {
    return;
  }

  var listingLat = $(mapDiv).data("latitude");
  var listingLong = $(mapDiv).data("longitude");

  var listingLocation = new google.maps.LatLng(listingLat, listingLong);
  var mapOptions = {
    zoom: 15,
    center: listingLocation,
    scrollwheel: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false
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

  // listing marker
  var marker = new google.maps.Marker({
    position: new google.maps.LatLng(listingLat, listingLong),
    icon: blackMapMarker,
    map: map,
    title: 'Your next home',
    zIndex: 99999
  });

  // use lat/long to get nearby locations
  var params = $.param({
    latitude: listingLat,
    longitude: listingLong,
  });

  // nearby locations
  $.getJSON('/locations.json?' + params, function(api) {
    $.each(api.locations, function(key, data) {
      var locationId = data.id;
      var locationPhoto = data['thumbnail_url'];
      var locationName = data.name;
      var locationAddress = data.address;
      var latLng = new google.maps.LatLng(data.latitude, data.longitude);

      // marker
      var marker = new google.maps.Marker({
        position: latLng,
        icon: greenMapMarker,
        map: map
      });
      marker.set('id', locationId);
      markers.push(marker);
      $(this).data('marker', marker);

      marker.addListener('click', function() {
        // close any open info windows
        closeInfoWindows(infoWindows);

        // open marker's info window
        var infoWindow = markerToInfoWindow[this.get('id')];
        infoWindow.open(map, this);
      });

      var contentString = '<a class="location-map-overlay" href="/locations/' + locationId + '">'
                        + '  <h3>' + locationName + '</h3>'
                        + '  <img class="img-small" src="' + locationPhoto + '">'
                        + '</a>';
      var infoWindow = new google.maps.InfoWindow({
        content: contentString,
        maxWidth: 250
      });
      infoWindows.push(infoWindow);
      markerToInfoWindow[marker.get('id')] = infoWindow;
    });
  });

  // nearby listings
  $.getJSON('/listings.json?' + params, function(api) {
    $.each(api.listings, function(key, data) {
      var listingId = data.id;
      var listingBeds = data.bedrooms;
      var listingBaths = data.bathrooms;
      var listingPrice = data.price;
      var listingPhoto = data.thumbnail_url;
      var latLng = new google.maps.LatLng(data.latitude, data.longitude);

      var bedBathDisplay = listingBeds + ' Bed / ' + listingBaths + ' Bath';

      // marker
      var marker = new google.maps.Marker({
        position: latLng,
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

      var contentString = '<div class="listing-info-window">'
                        + '  <a class="listing-map-overlay" href="/listings/' + listingId + '">'
                        + '    <img class="img-small" src="' + listingPhoto + '">'
                        + '  </a>'
                        + '  <div class="bed_bath">' + bedBathDisplay + '</div>'
                        + '  <h3 class="listing-maps-price">' + listingPrice + '</h3>'
                        + '</div>';
      var infoWindow = new google.maps.InfoWindow({
        content: contentString,
        maxWidth: 250
      });
      infoWindows.push(infoWindow);
      markerToInfoWindow[marker.get('id')] = infoWindow;
    });
  });
}

google.maps.event.addDomListener(window, 'load', listingInitialize);
