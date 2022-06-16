import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geoportal_social_services_app/map/styles_info.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapScreenPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MapScreenPageState();
  }

}

class MapScreenPageState extends State<MapScreenPage> {

  MapboxMapController? controller;
  final watercolorRasterId = "watercolorRaster";
  int selectedStyleId = 3;

  _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  static Future<void> addRaster(MapboxMapController controller) async {
    await controller.addSource(
      "web-map-source",
      RasterSourceProperties(
          tiles: [
            'http://202.45.146.139:8080/geoserver/GIID/wms?service=WMS&version=1.1.1&request=GetMap&layers=basemap_group&bbox={bbox-epsg-3857}&width=256&height=256&srs=EPSG:3857&format=image/png&transparent=true'
          ],
          tileSize: 256,
          attribution:
          'Map tiles by <a target="_top" rel="noopener" href="http://stamen.com">Stamen Design</a>, under <a target="_top" rel="noopener" href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a target="_top" rel="noopener" href="http://openstreetmap.org">OpenStreetMap</a>, under <a target="_top" rel="noopener" href="http://creativecommons.org/licenses/by-sa/3.0">CC BY SA</a>'),
    );
    await controller.addLayer(
        "web-map-source", "web-map-source", RasterLayerProperties());
  }

  static Future<void> addGeojsonCluster(MapboxMapController controller) async {
    await controller.addSource(
        "earthquakes",
        GeojsonSourceProperties(
            data:
            'https://docs.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson',
            cluster: true,
            clusterMaxZoom: 14, // Max zoom to cluster points on
            clusterRadius:
            50 // Radius of each cluster when clustering points (defaults to 50)
        ));
    await controller.addLayer(
        "earthquakes",
        "earthquakes-circles",
        CircleLayerProperties(circleColor: [
          Expressions.step,
          [Expressions.get, 'point_count'],
          '#51bbd6',
          100,
          '#f1f075',
          750,
          '#f28cb1'
        ], circleRadius: [
          Expressions.step,
          [Expressions.get, 'point_count'],
          20,
          100,
          30,
          750,
          40
        ]));
    await controller.addLayer(
        "earthquakes",
        "earthquakes-count",
        SymbolLayerProperties(
          textField: [Expressions.get, 'point_count_abbreviated'],
          textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          textSize: 12,
        ));
  }

  static Future<void> addVector(MapboxMapController controller) async {
    await controller.addSource(
        "terrain",
        VectorSourceProperties(
          url: "mapbox://mapbox.mapbox-terrain-v2",
        ));

    await controller.addLayer(
        "terrain",
        "contour",
        LineLayerProperties(
          lineColor: "#ff69b4",
          lineWidth: 1,
          lineCap: "round",
          lineJoin: "round",
        ),
        sourceLayer: "contour");
  }

  static Future<void> addImage(MapboxMapController controller) async {
    await controller.addSource(
        "radar",
        ImageSourceProperties(
            url: "https://docs.mapbox.com/mapbox-gl-js/assets/radar.gif",
            coordinates: [
              [-80.425, 46.437],
              [-71.516, 46.437],
              [-71.516, 37.936],
              [-80.425, 37.936]
            ]));

    await controller.addRasterLayer(
      "radar",
      "radar",
      RasterLayerProperties(rasterFadeDuration: 0),
    );
  }

  static Future<void> addVideo(MapboxMapController controller) async {
    await controller.addSource(
        "video",
        VideoSourceProperties(urls: [
          'https://static-assets.mapbox.com/mapbox-gl-js/drone.mp4',
          'https://static-assets.mapbox.com/mapbox-gl-js/drone.webm'
        ], coordinates: [
          [-122.51596391201019, 37.56238816766053],
          [-122.51467645168304, 37.56410183312965],
          [-122.51309394836426, 37.563391708549425],
          [-122.51423120498657, 37.56161849366671]
        ]));

    await controller.addRasterLayer(
      "video",
      "video",
      RasterLayerProperties(),
    );
  }

  static Future<void> addDem(MapboxMapController controller) async {
    await controller.addSource(
        "dem",
        RasterDemSourceProperties(
            url: "mapbox://mapbox.mapbox-terrain-dem-v1"));

    await controller.addLayer(
      "dem",
      "hillshade",
      HillshadeLayerProperties(
          hillshadeExaggeration: 1,
          hillshadeShadowColor: Colors.blue.toHexStringRGB()),
    );
  }

  static const _stylesAndLoaders = [
    StyleInfo(
      name: "Vector",
      baseStyle: MapboxStyles.LIGHT,
      addDetails: addVector,
      position: CameraPosition(target: LatLng(33.3832, -118.4333), zoom: 12),
    ),
    StyleInfo(
      name: "Dem",
      baseStyle: MapboxStyles.EMPTY,
      addDetails: addDem,
      position: CameraPosition(target: LatLng(33.5, -118.1), zoom: 8),
    ),
    StyleInfo(
      name: "Geojson cluster",
      baseStyle: MapboxStyles.SATELLITE_STREETS,
      addDetails: addGeojsonCluster,
      position: CameraPosition(target: LatLng(33.5, -118.1), zoom: 5),
    ),
    StyleInfo(
      name: "Raster",
      baseStyle: MapboxStyles.LIGHT,
      addDetails: addRaster,
      position: CameraPosition(target: LatLng(27.7172, 85.3240), zoom: 10),
    ),
    StyleInfo(
      name: "Image",
      baseStyle: MapboxStyles.DARK,
      addDetails: addImage,
      position: CameraPosition(target: LatLng(43, -75), zoom: 6),
    ),
    //video only supported on web
    if (kIsWeb)
      StyleInfo(
        name: "Video",
        baseStyle: MapboxStyles.SATELLITE,
        addDetails: addVideo,
        position: CameraPosition(
            target: LatLng(37.562984, -122.514426), zoom: 17, bearing: -96),
      ),
  ];

  _onStyleLoadedCallback() async {
    final styleInfo = _stylesAndLoaders[selectedStyleId];
    styleInfo.addDetails(controller!);
    controller!
        .animateCamera(CameraUpdate.newCameraPosition(styleInfo.position));
  }


  @override
  Widget build(BuildContext context) {

    final styleInfo = _stylesAndLoaders[selectedStyleId];
    final nextName =
        _stylesAndLoaders[(selectedStyleId + 1) % _stylesAndLoaders.length]
            .name;
    // TODO: implement build
    return Scaffold(
      body: MapboxMap(
          styleString: styleInfo.baseStyle,
          accessToken: 'pk.eyJ1IjoicGVhY2VuZXBhbCIsImEiOiJjajZhYzJ4ZmoxMWt4MzJsZ2NnMmpsejl4In0.rb2hYqaioM1-09E83J-SaA',
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoadedCallback,
          initialCameraPosition: const CameraPosition(target: LatLng(27.7172, 85.3240),
          zoom: 10.0
          )),
    );
  }
}