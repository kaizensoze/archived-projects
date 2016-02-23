function locationsInitialize() {
  var mapDiv = document.getElementById('locations-index-map');
  if ($(mapDiv).length < 1) {
    return;
  }

  var nooklynCenter = new google.maps.LatLng(40.6972217,-73.9411111)
  var mapOptions = {
    zoom: 14,
    center: nooklynCenter,
    zoomControl: true,
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

  $.getJSON('/api/v1/locations', function(api) {
    $.each(api.data, function(key, data) {
      var locationId = data.id;
      var locationPhoto = data.attributes['thumbnail'];
      var locationName = data.attributes.name;
      var locationAddress = data.attributes.address;
      var latLng = new google.maps.LatLng(data.attributes.latitude, data.attributes.longitude);

      var locationDisplayName = locationName.length > 25 ? locationName.substring(0, 23) + '...' : locationName;
      var locationDisplayAddress = locationAddress.replace(/(?:\r\n|\r|\n)/g, ', ');

      // add card
      // var card = '<div class="location-card" id="location_card_'+locationId+'" data-id="'+locationId+'" data-latitude="'+data.attributes.latitude+'" data-longitude="'+data.attributes.longitude+'" data-photo="'+locationPhoto+'">'
      //          + '  <a href="/locations/'+locationId+'"><img src="'+locationPhoto+'"></a>'
      //          + '  <div class="location-card-stub">'
      //          + '    <h2>'+locationName+'</h2>' // don't truncate for now
      //          + '    <hr>'
      //          + '    <h5>Address</h5>'
      //          + '    <address>'+locationDisplayAddress+'</address>'
      //          + '  </div>'
      //          + '</div>';
      // $('.locations-container').append(card);

      // marker
      var marker = new google.maps.Marker({
        position: latLng,
        map: map,
        icon: greenMapMarker,
        title: locationName
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

      // info window
      var contentString = '<a class="locations-map-overlay" href="/locations/' + locationId + '">'
                        + '  <div class="location-info-window text-center">'
                        + '    <img class="img-small" src="' + locationPhoto + '">'
                        + '  </div>'
                        + '  <h3>' + locationName + '</h3>'
                        + '  <br>'
                        + '  <p>' + locationDisplayAddress + '</p>'
                        + '  <hr>'
                        + '  <div class="text-center">'
                        + '    <a class="button btn-transparent-bk btn-3x" href="/locations/' + locationId + '">Learn More</a>'
                        + '  </div>'
                        + '</a>';
      var infoWindow = new google.maps.InfoWindow({
        content: contentString,
        maxWidth: 250
      });
      infoWindows.push(infoWindow);
      markerToInfoWindow[marker.get('id')] = infoWindow;
    });
  });
}

google.maps.event.addDomListener(window, 'load', locationsInitialize);
