var gMarker = '//nooklyn-files.s3.amazonaws.com/map/new/g-pin@1x.png';
var gMarkersize = new google.maps.Size(32, 32);

if (window.devicePixelRatio > 1.5) {
  gMarker = '//nooklyn-files.s3.amazonaws.com/map/new/g-pin@3x.png';
  gMarkersize = new google.maps.Size(32, 32);
};

var greenMapMarker = {
  url: gMarker,
  size: gMarkersize,
  scaledSize: new google.maps.Size(32, 32),
  origin: new google.maps.Point(0, 0),
  anchor: new google.maps.Point(16, 32)
};

var rMarker = '//nooklyn-files.s3.amazonaws.com/map/new/r-pin@1x.png';
var rMarkersize = new google.maps.Size(32, 32);

if (window.devicePixelRatio > 1.5) {
  rMarker = '//nooklyn-files.s3.amazonaws.com/map/new/r-pin@3x.png';
  rMarkersize = new google.maps.Size(32, 32);
};

var redMapMarker = {
  url: rMarker,
  size: rMarkersize,
  scaledSize: new google.maps.Size(32, 32),
  origin: new google.maps.Point(0, 0),
  anchor: new google.maps.Point(16, 32)
};

var bMarker = '//nooklyn-files.s3.amazonaws.com/map/new/b-pin@1x.png';
var bMarkersize = new google.maps.Size(32, 32);

if (window.devicePixelRatio > 1.5) {
  bMarker = '//nooklyn-files.s3.amazonaws.com/map/new/b-pin@3x.png';
  bMarkersize = new google.maps.Size(32, 32);
};

var blackMapMarker = {
  url: bMarker,
  size: bMarkersize,
  scaledSize: new google.maps.Size(32, 32),
  origin: new google.maps.Point(0, 0),
  anchor: new google.maps.Point(16, 32)
};

var mapStyles = [
  // WATER
  {
    featureType: 'water',
    elementType: 'geometry',
    stylers: [{
      color: '#a2daf2'
    }]
  },
  // LANDSCAPE
  {
    featureType: 'landscape.man_made',
    elementType: 'geometry',
    stylers: [{
      color: '#f7f1df'
    }]
  },
  {
    featureType: 'landscape.natural',
    elementType: 'geometry',
    stylers: [{
      color: '#d0e3b4'
    }]
  },
  {
    featureType: 'landscape.natural.terrain',
    elementType: 'geometry',
    stylers: [{
      visibility: 'off'
    }]
  },
  // POINTS OF INTEREST
  {
    featureType: "poi",
    elementType: "label",
    stylers: [
      { visibility: "simplified" }
    ]
  },{
    featureType: "poi",
    elementType: "geometry.fill",
    stylers: [
      { visibility: "off" }
    ]
  },{
    featureType: "poi.park",
    elementType: "geometry",
    stylers: [
      { visibility: "on" }
    ]
  },
  // ROADS
  {
    featureType: 'road.highway',
    elementType: 'geometry.fill',
    stylers: [{
      color: '#f1e577'
    }]
  },
  {
    featureType: 'road.highway',
    elementType: 'geometry.stroke',
    stylers: [{
      color: '#efd151'
    }]
  },
  {
    featureType: 'road.highway.controlled_access',
    elementType: 'labels.text',
    stylers: [{
      visibility: 'off'
    }]
  },
  {
    featureType: 'road.arterial',
    elementType: 'geometry.fill',
    stylers: [{
      color: '#ffffff'
    }]
  },
  {
    featureType: 'road.local',
    elementType: 'geometry.fill',
    stylers: [{
      color: 'black'
    }]
  },
  // TRANSIT
  {
    featureType: 'transit.station.airport',
    elementType: 'geometry.fill',
    stylers: [{
      color: '#cfb2db'
    }]
  }
];

function closeInfoWindows(infoWindows) {
  $.each(infoWindows, function() {
    if (this.getMap() != null) {
      this.close();
    }
  });
}
