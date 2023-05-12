import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_map/flutter_map.dart';

import 'nav-drawer.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var Array, id_victima, id_agresor, id_orden, radio;
  var PosVictima, PosAgresor;
  double Latvictima = 19.22182601;
  double Latagresor = 19.22182601;
  double lonvictima = -70.514254;
  double lonagresor = -70.514254;
  double radius = 60;

//const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    _operation();

    final circleMarkers = <CircleMarker>[
      CircleMarker(
          point: LatLng(Latvictima, lonvictima),
          color: Colors.blue.withOpacity(0.2),
          borderStrokeWidth: 1,
          useRadiusInMeter: true,
          radius: radius // 2000 meters | 2 km
          ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text('Mapa'),
        ),
        body: Center(
            child: FlutterMap(
          options: MapOptions(
            center: LatLng(Latvictima, lonvictima),
            zoom: 18,
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
                  point: LatLng(Latvictima, lonvictima),
                  builder: (cxt) => Icon(
                    Icons.pin_drop,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                Marker(
                  point: LatLng(Latagresor, lonagresor),
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

  Future _operation() async {
    var connection = PostgreSQLConnection("10.0.0.99", 5432, "appdb",
        username: "appuser", password: "strongpasswordapp", useSSL: false);
    String? id_app_flutter = await PlatformDeviceId.getDeviceId;
    await connection.open();

    Array = await connection.query(
        "SELECT * FROM orden INNER JOIN ubicacion_victima ON orden.id_victima=ubicacion_victima.id_victima where ubicacion_victima.id_app_movil='$id_app_flutter' LIMIT 1");

    id_orden = Array[0][0];
    id_victima = Array[0][1].toString();
    id_agresor = Array[0][2].toString();
    radio = Array[0][3];
    PosVictima = await connection.query(
        "select * from ubicacion_victima where id_victima = '$id_victima' order by id_ubicacion_victima DESC LIMIT 1");
    PosAgresor = await connection.query(
        "select * from ubicacion_agresor where id_agresor = '$id_agresor' order by id_ubicacion_agresor DESC LIMIT 1");

    await connection.close();
    //radius = double.parse(radio.toString());
    Latvictima = double.parse(PosVictima[0][4].toString());
    Latagresor = double.parse(PosAgresor[0][3].toString());
    lonvictima = double.parse(PosVictima[0][3].toString());
    lonagresor = double.parse(PosAgresor[0][2].toString());

    //await Future.delayed(Duration(minutes: 1));
    Future.delayed(Duration(seconds: 1), () {
      // <-- Delay here
      setState(() {
        print(radius.toString());
      });
    });
  }
}
