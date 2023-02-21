import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'nav-drawer.dart';

class HomePage extends StatelessWidget {
  final circleMarkers = <CircleMarker>[
    CircleMarker(
        point: LatLng(19.221870, -70.514107),
        color: Colors.blue.withOpacity(0.2),
        borderStrokeWidth: 1,
        useRadiusInMeter: true,
        radius: 100 // 2000 meters | 2 km
        ),
  ];
//const HomePage({super.key});
  //String victima;
  List<List<dynamic>> victima;
  //String orden;
  HomePage({super.key, required this.victima});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text('Bienvenido ' + victima[0][1]),
        ),
        body: Center(
            child: FlutterMap(
          options: MapOptions(
            center: LatLng(19.221870, -70.514107),
            zoom: 13,
          ),
          nonRotatedChildren: [
            AttributionWidget.defaultWidget(
              source: 'OpenStreetMap contributors',
              onSourceTapped: null,
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(19.221870, -70.514107),
                  builder: (cxt) => Icon(
                    Icons.pin_drop,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                Marker(
                  point: LatLng(19.221412, -70.514716),
                  builder: (cxt) => Icon(
                    Icons.pin_drop,
                    color: Colors.green,
                    size: 50,
                  ),
                )
              ],
            ),
            CircleLayer(circles: circleMarkers),
          ],
        )),
      ),
    );
  }
}
