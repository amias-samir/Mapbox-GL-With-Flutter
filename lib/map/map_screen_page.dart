import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoportal_social_services_app/map/map_route_navigation.dart';
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
  MapBoxNavigationViewController? navigationViewController;
  MapBoxOptions ? _options;
  final watercolorRasterId = "watercolorRaster";
  int selectedStyleId = 2;
  MapBoxNavigation? _directions;
  UserLocation? userLocation;


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  _onMapCreated(MapboxMapController controller)   {
    this.controller = controller;
    

    controller.onFeatureTapped.add(onFeatureTap);


  }


  @override
  void initState() {
    super.initState();
    // navigationViewController = MapBoxNavigationViewController(id, (value) { })
    _directions = MapBoxNavigation(onRouteEvent: _onRouteEvent);
    getStyleJson();
  }

  var _distanceRemaining;
  var _durationRemaining;
  bool? _arrived = false;
  String? _instruction;
  bool?  _routeBuilt = false;
  bool?  _isNavigating= false;
  bool? _isMultipleStop= false;
  Future<void> _onRouteEvent(e) async {

    _distanceRemaining = await _directions!.distanceRemaining;
    _durationRemaining = await _directions!.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        _arrived = true;
        if (_isMultipleStop!) {
          await Future.delayed(Duration(seconds: 3));
          await navigationViewController!.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        _routeBuilt = false;
        _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
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
    await controller.addLayer("web-map-source", "web-map-source", RasterLayerProperties());
  }

  static Future<void> addGeojsonCluster(MapboxMapController controller) async {



    await controller.addSource(
        "default",
        const VectorSourceProperties(
            tiles: ["https://assessment.naxa.com.np/api/site_vectortile/{z}/{x}/{y}?project=6"],
            scheme: 'xyz',
            promoteId: '{default : id}'
        ));

    await controller.addLayer(
        "default",
        "customLayer",
        const FillLayerProperties(
            fillColor: '#9f69b4'
        ),
        sourceLayer: 'default'
    );

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
        "web-map-source", "web-map-source", RasterLayerProperties(),
        belowLayerId: 'customLayer');


    await controller.addSource(
        "terrain",
        VectorSourceProperties(
          url: "https://api.maptiler.com/tiles/ch-swisstopo-lbm/{z}/{x}/{y}.pbf?key=yVXqeQeRSeuQqtFoouno",
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

    await controller.addSource(
        "health",
        GeojsonSourceProperties(
            data:
            'https://admin.nationalgeoportal.gov.np/geoserver/geonode/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=geonode:All_Nepal_Final_short&outputFormat=application/json',
            // 'https://admin.nationalgeoportal.gov.np/geoserver/geonode/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=geonode:First_order_controlPoint0&outputFormat=application/json',
            // 'https://docs.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson',
            cluster: true,
            clusterMaxZoom: 14, // Max zoom to cluster points on
            clusterRadius:
            50 // Radius of each cluster when clustering points (defaults to 50)
        )
    );

    await controller.addSource(
        "police",
        GeojsonSourceProperties(
            data:
            // 'https://admin.nationalgeoportal.gov.np/geoserver/geonode/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=geonode:All_Nepal_Final_short&outputFormat=application/json',
            'https://admin.nationalgeoportal.gov.np/geoserver/geonode/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=geonode:First_order_controlPoint0&outputFormat=application/json',
            // 'https://docs.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson',
            cluster: true,
            clusterMaxZoom: 14, // Max zoom to cluster points on
            clusterRadius:
            50 // Radius of each cluster when clustering points (defaults to 50)
        )
    );


    await controller.addLayer(
        "health",
        "health-circles",
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

    controller.addLayer(
        "police",
        "police-circles",
        CircleLayerProperties(circleColor: [
          Expressions.step,
          [Expressions.get, 'point_count'],
          '#5163d6',
          100,
          '#715875',
          750,
          '#8297b1'
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
        "health",
        "health-count",
        SymbolLayerProperties(
          textField: [Expressions.get, 'point_count_abbreviated'],
          textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          textSize: 12,
          // iconColor: Colors.red
        ));

    await controller.addLayer(
        "police",
        "police-count",
        SymbolLayerProperties(
          textField: [Expressions.get, 'point_count_abbreviated'],
          textFont: ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
          textSize: 12,
          // iconColor: Colors.blue
        ));
  }

  static Future<void> addVector(MapboxMapController controller) async {


    await controller.addSource(
        "default",
        const VectorSourceProperties(
          tiles: ["https://assessment.naxa.com.np/api/site_vectortile/{z}/{x}/{y}?project=6"],
          scheme: 'xyz',
          promoteId: '{default : id}'
        ));

    await controller.addLayer(
        "default",
        "customLayer",
        const FillLayerProperties(
          fillColor: '#9f69b4'
        ),
      sourceLayer: 'default'
        );

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

  var jsonResult;
  getStyleJson () async{
    String data = await DefaultAssetBundle.of(context).loadString("assets/json/mapbox_style.json");
     jsonResult = jsonDecode(data);
  }

  // Map stylesJson = json.decode('{"sources": {"": {"attribution": "<a href=<a href="http://www.openmaptiles.org/" target="_blank">&copy; OpenMapTiles</a> <a href="http://www.openstreetmap.org/about/" target="_blank">&copy; OpenStreetMap contributors</a>","tiles": ["https://pccmis.karnali.gov.np/api/v1/layer_vectortile/{z}/{x}/{y}/?layer=municipality&pro_code=3"],"type": "vector"}},"layers": {"id": "polyfill","layout": {"visibility": "visible"},"paint": {"fill-color": "hsl(0, 100%, 50%)","fill-opacity": 0.3,"line-color": "hsl(205, 56%, 73%)"},"source": "default","source-layer": "default","type": "fill"},{"id": "polyline","type": "line","metadata": {},"source": "default","source-layer": "default","layout": {"line-cap": "round","line-join": "round"},"paint": {"line-color": "hsl(47, 26%, 88%)","line-width": {"base": 1.2,"stops": [[15, 1],[17, 4]]}}}]}');

  static const _stylesAndLoaders = [
    StyleInfo(
      name: "Vector",
      baseStyle: MapboxStyles.LIGHT,
      addDetails: addVector,
      position: CameraPosition(target: LatLng(28.9873, 80.1652), zoom: 12),
    ),
    StyleInfo(
      name: "Dem",
      baseStyle: MapboxStyles.EMPTY,
      addDetails: addDem,
      position: CameraPosition(target: LatLng(33.5, -118.1), zoom: 8),
    ),
    StyleInfo(
      name: "Geojson cluster",
      baseStyle: MapboxStyles.LIGHT,
      addDetails: addGeojsonCluster,
      position: CameraPosition(target: LatLng(27.7172, 85.3240), zoom: 9),
    ),
    StyleInfo(
      name: "Raster",
      baseStyle: MapboxStyles.LIGHT,
      addDetails: addRaster,
      position: CameraPosition(target: LatLng(27.7172, 85.3240), zoom:5 ),
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



   onFeatureTap(dynamic featureId, Point point, LatLng latLng) async {
    debugPrint('onFeatureTap ID: ${featureId.toString()}  \n', );
    debugPrint('onFeatureTap Point:  X: ${point.x} ,  Y: ${point.y}  \n', );
    debugPrint('onFeatureTap LatLng: ${latLng.toString()}  \n', );

    // debugPrint('onFeatureTap layerProperties: ${controller!.symbolManager!.allLayerProperties.single.toJson()}  \n', );



    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     // action: SnackBarAction(
    //     //   label: 'Action',
    //     //   onPressed: () {
    //     //     // Code to execute.
    //     //   },
    //     // ),
    //     content: Text('Feature ID: ${featureId.toString()} \n '
    //         'Coordinates: ${latLng.toString()}'),
    //     duration: const Duration(milliseconds: 1500),
    //     width: 280.0, // Width of the SnackBar.
    //     padding: const EdgeInsets.symmetric(
    //       horizontal: 8.0, // Inner padding for SnackBar content.
    //     ),
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(10.0),
    //     ),
    //   ),
    // );

     // showInSnackBar('Feature ID: ${featureId.toString()} \n ''Coordinates: ${latLng.toString()}');
     Fluttertoast.showToast(msg: 'Feature ID: ${featureId.toString()} \n '
         'Coordinates: ${latLng.toString()}');



    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) =>  MapRouteNavigationScreen(
    //     latLngBounds: StartDestinationCoords(northeast:  const LatLng(27.6588, 85.3247),
    //         southwest: const LatLng(27.69335, 85.3782)),)),
    // );

    // _options = MapBoxOptions(
    //     initialLatitude: latLng.latitude,
    //     initialLongitude: latLng.longitude,
    //     zoom: 13.0,
    //     tilt: 0.0,
    //     bearing: 0.0,
    //     enableRefresh: false,
    //     alternatives: true,
    //     voiceInstructionsEnabled: true,
    //     bannerInstructionsEnabled: true,
    //     allowsUTurnAtWayPoints: true,
    //     mode: MapBoxNavigationMode.drivingWithTraffic,
    //     mapStyleUrlDay: "https://url_to_day_style",
    //     mapStyleUrlNight: "https://url_to_night_style",
    //     units: VoiceUnits.imperial,
    //     simulateRoute: true,
    //     language: "en");
    //
    // WayPoint ? cityHall ;
    // if(userLocation != null){
    //   cityHall = WayPoint(name: "Current", latitude: userLocation!.position.latitude, longitude: userLocation!.position.longitude);
    // }else{
    //   cityHall = WayPoint(name: "Current", latitude: 27.721963, longitude: 85.372912);
    // }
    // WayPoint ?  downTown = WayPoint(name: "Destination", latitude: latLng.latitude, longitude: latLng.longitude);
    //
    // var wayPoints = <WayPoint>[];
    // wayPoints.add(cityHall);
    // wayPoints.add(downTown);
    //
    // await _directions!.startNavigation(wayPoints: wayPoints, options: _options!);

   }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState?.showSnackBar( SnackBar(content: Text(value),
    ));
  }



  @override
  Widget build(BuildContext context) {

    final styleInfo = _stylesAndLoaders[selectedStyleId];

    final nextName =
        _stylesAndLoaders[(selectedStyleId + 1) % _stylesAndLoaders.length]
            .name;
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: MapboxMap(
            styleString: styleInfo.baseStyle,
            accessToken: 'pk.eyJ1IjoicGVhY2VuZXBhbCIsImEiOiJjajZhYzJ4ZmoxMWt4MzJsZ2NnMmpsejl4In0.rb2hYqaioM1-09E83J-SaA',
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoadedCallback,
            // initialCameraPosition: const CameraPosition(target: LatLng(27.7172, 85.3240),
            initialCameraPosition: const CameraPosition(target: LatLng(28.987280, 80.1652),
            zoom: 10.0,
            ),
        myLocationEnabled: true,
        onUserLocationUpdated: (userLocation1){
              userLocation = userLocation1;
        },
        // cameraTargetBounds: CameraTargetBounds(LatLngBounds( southwest: const LatLng(26.3978980576, 80.0884245137), northeast: const LatLng(26.3978980576, 80.0884245137))),
        ),
      ),
    );
  }
}