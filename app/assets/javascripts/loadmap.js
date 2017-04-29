var loadMap = function(mapgeojson, zoomlevel, centerLongitude, centerLatitude) {
    var layer = ga.layer.create('ch.swisstopo.pixelkarte-farbe');
    var map = new ga.Map({
        target: 'map',
        layers: [layer],
        view: new ol.View({
            resolution: zoomlevel,
            center: [centerLongitude, centerLatitude]
        })
    });

    var olSource = new ol.source.Vector();
    var vectorLayer = new ol.layer.Vector({
        source: olSource
    });

    var geojsonFormat = new ol.format.GeoJSON();


    // Get Coordinates from Tubecam
    var getTubesCoordinates = function () {
        $.ajax({
            type: 'GET',
            url: 'tubes.json',
            success: function (data) {
                console.log(data);
            }
        });
    };

    // Load and apply GeoJSON file function
    var setLayerSource = function () {
        $.ajax({
            type: 'GET',
            url: 'http://api3.geo.admin.ch/examples/geojson_example.json',
            success: function (data) {
                olSource.clear();
                olSource.addFeatures(
                    geojsonFormat.readFeatures(data)
                );
            }
        });
    };

    // Load and apply styling file function
    var setLayerStyle = function () {
        $.ajax({
            type: 'GET',
            url: 'http://api3.geo.admin.ch/examples/geojson_style_example.json',
            success: function (data) {
                var olStyleForVector = new ga.style.StylesFromLiterals(data);
                vectorLayer.setStyle(function (feature) {
                    return [olStyleForVector.getFeatureStyle(feature)];
                });
            }
        });
    };


    var applyGeojsonConfig = function (mapgeo) {

        // Load Styling file
        setLayerStyle();

        // Load Geojson file
        // setLayerSource();

        olSource.clear();
        olSource.addFeatures(geojsonFormat.readFeatures(mapgeo));


        // Only one vector layer is added


        // Add Geojson layer
        map.addLayer(vectorLayer);

    }
    applyGeojsonConfig(mapgeojson);

    // Clear vector layer from map
    var clearLayer = function () {
        if (vectorLayer) {
            map.removeLayer(vectorLayer);
        }
    };

    // Popup showing the position the user clicked
    var popup = new ol.Overlay({
        element: document.getElementById('popup')
    });
    map.addOverlay(popup);

    map.on('singleclick', function (evt) {
        var feature = map.forEachFeatureAtPixel(evt.pixel, function (feat, layer) {
            return feat;
        });
        var element = $(popup.getElement());
        element.popover('destroy');
        if (feature) {
            popup.setPosition(evt.coordinate);
            element.popover({
                'placement': 'top',
                'animation': false,
                'html': true,
                'content': feature.get('description')
            }).popover('show');
        }
    });
}