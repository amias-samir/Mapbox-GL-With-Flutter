import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapScreenPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MapScreenPageState();
  }

}

class MapScreenPageState extends State<MapScreenPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: MapboxMap(
        accessToken: 'pk.eyJ1IjoicGVhY2VuZXBhbCIsImEiOiJjajZhYzJ4ZmoxMWt4MzJsZ2NnMmpsejl4In0.rb2hYqaioM1-09E83J-SaA',
          initialCameraPosition: const CameraPosition(target: LatLng(27.7172, 85.3240),
          zoom: 14.0
          )),
    );
  }
}