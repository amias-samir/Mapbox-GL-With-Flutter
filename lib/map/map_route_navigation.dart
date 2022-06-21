import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geoportal_social_services_app/map/styles_info.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapRouteNavigationScreen extends StatefulWidget{

 final  StartDestinationCoords? latLngBounds;

  const MapRouteNavigationScreen({super.key, this.latLngBounds});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MapRouteNavigationState();
  }

}

class MapRouteNavigationState extends State<MapRouteNavigationScreen> {

  String _platformVersion = 'Unknown';
  String _instruction = "";
  final WayPoint _origin = WayPoint(
      name: "Way Point 1",
      latitude: 27.5125,
      longitude: 85.3291);
  WayPoint? _stop1 ;
  WayPoint? _stop2;
  // WayPoint? _stop3 ;
  WayPoint? _stop4;

  MapBoxNavigation? _directions;
  MapBoxOptions? _options;

  bool _isMultipleStop = false;
  double ?_distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController? _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _stop1 = WayPoint(
        name: "Way Point 2",
        latitude: widget.latLngBounds!.northeast.latitude,
        longitude: widget.latLngBounds!.northeast.longitude);
    _stop2 = WayPoint(
        name: "Way Point 3",
        latitude: 27.7219,
        longitude: 85.3732);
    _stop4 = WayPoint(
        name: "Way Point 5",
        latitude: widget.latLngBounds!.southwest.latitude,
        longitude: widget.latLngBounds!.southwest.longitude);

    initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
    _options = MapBoxOptions(
      //initialLatitude: 36.1175275,
      //initialLongitude: -115.1839524,
        zoom: 15.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: false,
        animateBuildRoute: true,
        longPressDestinationEnabled: true,
        language: "en");

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await _directions!.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text('Running on: $_platformVersion\n'),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          "Full Screen Navigation",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: Text("Start A to B"),
                          onPressed: () async {
                            var wayPoints = <WayPoint>[];
                            wayPoints.add(_origin);
                            wayPoints.add(_stop1!);

                            await _directions!.startNavigation(
                                wayPoints: wayPoints,
                                options: MapBoxOptions(
                                    mode:
                                    MapBoxNavigationMode.drivingWithTraffic,
                                    simulateRoute: false,
                                    language: "en",
                                    units: VoiceUnits.metric));
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: Text("Start Multi Stop"),
                          onPressed: () async {
                            _isMultipleStop = true;
                            var wayPoints = <WayPoint>[];
                            wayPoints.add(_origin);
                            wayPoints.add(_stop1!);
                            wayPoints.add(_stop2!);
                            wayPoints.add(_stop4!);
                            wayPoints.add(_origin);

                            await _directions!.startNavigation(
                                wayPoints: wayPoints,
                                options: MapBoxOptions(
                                    mode: MapBoxNavigationMode.driving,
                                    simulateRoute: true,
                                    language: "en",
                                    allowsUTurnAtWayPoints: true,
                                    units: VoiceUnits.metric));
                          },
                        )
                      ],
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          "Embedded Navigation",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: Text(_routeBuilt && !_isNavigating
                              ? "Clear Route"
                              : "Build Route"),
                          onPressed: _isNavigating
                              ? null
                              : () {
                            if (_routeBuilt) {
                              _controller!.clearRoute();
                            } else {
                              var wayPoints = <WayPoint>[];
                              wayPoints.add(_origin);
                              wayPoints.add(_stop1!);
                              wayPoints.add(_stop2!);
                              wayPoints.add(_stop4!);
                              wayPoints.add(_origin);
                              _isMultipleStop = wayPoints.length > 2;
                              _controller!.buildRoute(
                                  wayPoints: wayPoints);
                            }
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: Text("Start "),
                          onPressed: _routeBuilt && !_isNavigating
                              ? () {
                            _controller!.startNavigation();
                          }
                              : null,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          child: Text("Cancel "),
                          onPressed: _isNavigating
                              ? () {
                            _controller!.finishNavigation();
                          }
                              : null,
                        )
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Long-Press Embedded Map to Set Destination",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.grey,
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: (Text(
                          _instruction == null || _instruction.isEmpty
                              ? "Banner Instruction Here"
                              : _instruction,
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20, top: 20, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("Duration Remaining: "),
                              Text(_durationRemaining != null
                                  ? "${(_durationRemaining! / 60).toStringAsFixed(0)} minutes"
                                  : "---")
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text("Distance Remaining: "),
                              Text(_distanceRemaining != null
                                  ? "${(_distanceRemaining! * 0.000621371).toStringAsFixed(1)} miles"
                                  : "---")
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider()
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey,
                child: MapBoxNavigationView(
                    options: _options,
                    onRouteEvent: _onEmbeddedRouteEvent,
                    onCreated:
                        (MapBoxNavigationViewController controller) async {
                      _controller = controller;
                      controller.initialize();
                    }),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    _distanceRemaining = await _directions!.distanceRemaining;
    _durationRemaining = await _directions!.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        RouteProgressEvent? progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction!;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(Duration(seconds: 3));
          await _controller!.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }
}