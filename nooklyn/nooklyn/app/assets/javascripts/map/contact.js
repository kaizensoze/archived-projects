function contactInitialize() {
  var mapDiv = document.getElementById('nooklyn_contact_page_map');
  if ($(mapDiv).length < 1) {
    return;
  }

  // enable the visual refresh
  google.maps.visualRefresh = true;

  var nooklynCenter = new google.maps.LatLng(40.722736512395284, -73.93933206796646);
  var bushwickLocation = new google.maps.LatLng(40.70839317279136, -73.92178773880005);
  var greenpointLocation = new google.maps.LatLng(40.72240311578926, -73.94992344081402);
  var crownLocation = new google.maps.LatLng(40.6726417, -73.9572593);
  var mapOptions = {
    zoom: 13,
    center: nooklynCenter,
    scrollwheel: false,
    disableDefaultUI: true,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    styles: [
      {
        "featureType": "all",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "saturation": 36
          },
          {
            "color": "#000000"
          },
          {
            "lightness": 40
          }
        ]
      },
      {
        "featureType": "all",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "visibility": "on"
          },
          {
            "color": "#000000"
          },
          {
            "lightness": 16
          }
        ]
      },
      {
        "featureType": "all",
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 20
          }
        ]
      },
      {
        "featureType": "administrative",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 17
          },
          {
            "weight": 1.2
          }
        ]
      },
      {
        "featureType": "landscape",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 20
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 21
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 17
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry.stroke",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 29
          },
          {
            "weight": 0.2
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 18
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 16
          }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 19
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          },
          {
            "lightness": 17
          }
        ]
      }
    ]
  };

  var map = new google.maps.Map(mapDiv, mapOptions);

  var officePin = new google.maps.MarkerImage("//nooklyn-files.s3.amazonaws.com/map/blackpin.png",
    new google.maps.Size(32, 32), new google.maps.Point(0, 0), new google.maps.Point(16, 32));

  // bushwick info window
  var bushwickContent = '<div id="map_content">'+
                        '<h1 id="firstHeading">Bushwick Main Office</h1>'+
                        '<div id="bodyContent">'+
                        '<p class="text-center">28 Scott Avenue, Suite #106<br>' +
                        'Brooklyn, New York 11237<br>'+
                        '</div>'+
                        '</div>';
  var bushwickWindow = new google.maps.InfoWindow({
      content: bushwickContent
  });

  // bushwick marker
  var bushwickMarker = new google.maps.Marker({
    position: bushwickLocation,
    map: map,
    icon: officePin,
    title: 'Bushwick Main Office'
  });
  bushwickMarker.addListener('click', function() {
    bushwickWindow.open(map, bushwickMarker);
  });
  bushwickWindow.open(map, bushwickMarker);

  // greenpoint info window
  var greenpointContent = '<div id="map_content">'+
                          '<h1 id="firstHeading">Greenpoint Branch Office</h1>'+
                          '<div id="bodyContent">'+
                          '<p class="text-center">568 Manhattan Ave. Store B<br>' +
                          'Brooklyn, New York 11222'+
                          '</div>'+
                          '</div>';
  var greenpointWindow = new google.maps.InfoWindow({
      content: greenpointContent
  });

  // greenpoint marker
  var greenpointMarker = new google.maps.Marker({
    position: greenpointLocation,
    map: map,
    icon: officePin,
    title: 'Greenpoint Branch Office'
  });
  greenpointMarker.addListener('click', function() {
    greenpointWindow.open(map, greenpointMarker);
  });
  greenpointWindow.open(map, greenpointMarker);

  // crown heights info window
  var crownContent = '<div id="map_content">'+
                     '<h1 id="firstHeading">Crown Heights Branch Office</h1>'+
                     '<div id="bodyContent">'+
                     '<p class="text-center">765 Franklin Avenue<br>' +
                     'Brooklyn, New York 11238'+
                     '</div>'+
                     '</div>';
  var crownWindow = new google.maps.InfoWindow({
      content: crownContent
  });

  // crown heights marker
  var crownMarker = new google.maps.Marker({
    position: crownLocation,
    map: map,
    icon: officePin,
    title: 'Crown Heights Branch Office',
    zIndex: 1000,
  });
  crownMarker.addListener('click', function() {
    crownWindow.open(map, crownMarker);
  });
  crownWindow.open(map, crownMarker);
}

google.maps.event.addDomListener(window, 'load', contactInitialize);
