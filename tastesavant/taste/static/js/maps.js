function initialize(lat, lng) {
    var myOptions = {
        zoom: 12,
        center: new google.maps.LatLng(lat, lng),
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        panControl: false,
        zoomControl: true,
        mapTypeControl: false,
        scaleControl: false,
        streetViewControl: false,
        overviewMapControl: false,
        scrollwheel: false
    }

    var map = new google.maps.Map(document.getElementById("google-map"), myOptions);
    setMarkers(map, restaurants);
}

function AutoCenter() {
    //  Create a new viewpoint bound
    var bounds = new google.maps.LatLngBounds();
    //  Go through each...
    $.each(markers, function (index, marker) {
        bounds.extend(marker.position);
    });
    //  Fit these bounds to the map
    map.fitBounds(bounds);
}

function setMarkers(map, locations) {
    var shadow = new google.maps.MarkerImage(
        "http://storage.tastesavant.com.s3.amazonaws.com/images/shadow-map-cursor.png",
        new google.maps.Size(45, 36),
        new google.maps.Point(0,0),
        new google.maps.Point(9, 34));

    var shape = {
        coord: [1, 1, 1, 20, 18, 20, 18 , 1],
        type: 'poly'
    };

    if (locations.length != 0) {
        var bounds = new google.maps.LatLngBounds();
        for (var i = 0; i < locations.length; i++) {
            var id = i+1;
            if (locations.length > 1 && locations.length <= 10) {
                var image = new google.maps.MarkerImage(
                    "http://storage.tastesavant.com.s3.amazonaws.com/images/map-pointers/" + id + ".png",
                    new google.maps.Size(26, 36),
                    new google.maps.Point(0,0),
                    new google.maps.Point(9, 34));
            }
            else {
                var image = new google.maps.MarkerImage(
                    "http://storage.tastesavant.com.s3.amazonaws.com/images/map-pointers/0.png",
                    new google.maps.Size(26, 36),
                    new google.maps.Point(0,0),
                    new google.maps.Point(9, 34));
            }

            var restaurant = locations[i];
            var myLatLng = new google.maps.LatLng(restaurant[1], restaurant[2]);
            var marker = new google.maps.Marker({
                position: myLatLng,
                map: map,
                shadow: shadow,
                icon: image,
                shape: shape,
                title: restaurant[0],
                zIndex: restaurant[3],
                id: id
            });

            google.maps.event.addListener(marker, 'click', function () {
                var row_id = 'result' + this.id;
                var all_rows = $$('div[class^=result-link]');
                all_rows.each(function(el){

                });
                window.location.hash=row_id;

                $(row_id).setStyle('background', '#FEFCE7');
                $(row_id).setStyle('border-bottom', 'solid 1px #E8E8E8');
            });

            bounds.extend(myLatLng);
            if (locations.length > 1) {
                map.fitBounds(bounds);
            }
            else if (locations.length == 1) {
                map.setCenter(bounds.getCenter());
                map.setZoom(16);
            }
        }
    }
}
