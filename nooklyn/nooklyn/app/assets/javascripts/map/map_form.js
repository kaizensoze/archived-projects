function mapForm() {
  var mapDiv = document.getElementById('form-map');
  if ($(mapDiv).length < 1) {
    return;
  }

  // enable the visual refresh
  google.maps.visualRefresh = true;

  var nooklynCenter = new google.maps.LatLng(40.722736512395284, -73.93933206796646);
  var mapOptions = {
    zoom: 13,
    center: nooklynCenter,
    scrollwheel: false,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: false
  };
  var map = new google.maps.Map(mapDiv, mapOptions);

  // form address-related info
  var formLat = document.getElementById("listing_latitude");
  var formLong = document.getElementById("listing_longitude");
  var formAddressField = document.getElementsByClassName("map-autocomplete-address")[0];

  // map input
  var input = document.getElementById('pac-input');

  var types = document.getElementById('type-selector');
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(input);
  map.controls[google.maps.ControlPosition.TOP_CENTER].push(types);

  var autocomplete = new google.maps.places.Autocomplete(input);
  autocomplete.bindTo('bounds', map);

  // add marker
  var marker = new google.maps.Marker({
    map: map,
    icon: blackMapMarker
  });

  // set marker lat/lng
  if (formLat && formLong) {
    var latLng = new google.maps.LatLng(formLat.value, formLong.value);
    marker.setPosition(latLng);
    map.panTo(latLng);
  }

  // set marker title
  if (formAddressField) {
    marker.setTitle(formAddressField.value);
  }

  autocomplete.addListener('place_changed', function(mk) {
    // get place from input
    var place = autocomplete.getPlace();
    if (!place.geometry) {
      return;
    }

    if (place.geometry.viewport) {
      map.fitBounds(place.geometry.viewport);
    } else {
      map.setCenter(place.geometry.location);
      map.setZoom(17);
    }

    // place new marker
    marker.setTitle(place.formatted_address);
    marker.setPosition(place.geometry.location);

    // update form to reflect new marker
    if (formLat && formLong) {
      formLat.value = marker.getPosition().lat();
      formLong.value = marker.getPosition().lng();
    }
    $('.map-autocomplete-address').val(place.formatted_address);
  });

  var transitLayer = new google.maps.TransitLayer();
  transitLayer.setMap(map);

  var fieldBinding, checkboxBinding;
  fieldBinding = function($field, $checkboxes, separator) {
    var existing;
    existing = $field.val().split(separator);
    return $.each(existing, function(i, item) {
      var $checkbox;
      $checkbox = $checkboxes.filter('input[value="' + item + '"]');
      $checkbox.attr('checked', true);
      return $checkbox.parent().addClass('checked');
    });
  };
  checkboxBinding = function($checkbox, $field, separator) {
    var checked, existing, fieldContainsLabel, label, output;
    label = $checkbox.val();
    existing = $field.val();
    checked = $checkbox.prop('checked');
    fieldContainsLabel = existing.indexOf(label);
    if (checked && fieldContainsLabel === -1) {
      if ((existing != null) && existing !== "") {
        $field.val(existing + separator + label);
      } else {
        $field.val(label);
      }
      return $checkbox.parent().addClass('checked');
    } else if (!checked && fieldContainsLabel !== -1) {
      output = existing.replace(separator + label, "");
      output = output.replace(label + separator, "");
      output = output.replace(label, "");
      $field.val(output);
      return $checkbox.parent().removeClass('checked');
    }
  };
  fieldBinding($("#listing_subway_line"), $(".subway-lines input"), " ");
  fieldBinding($("#listing_amenities"), $(".amenities input"), "\n");
  $(".subway-lines input").on("change", function() {
    return checkboxBinding($(this), $("#listing_subway_line"), " ");
  });
  $(".amenities input").on("change", function() {
    return checkboxBinding($(this), $("#listing_amenities"), "\n");
  });
}

google.maps.event.addDomListener(window, 'load', mapForm);
