import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:mobile_app/local_notice_service.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:web_socket_channel/io.dart';
import 'package:mobile_app/local_notice_service.dart';

import 'dart:math' show cos, sqrt, asin;

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
  double radius = 0;
  double size_marker_agresor = 50;

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
                    size: size_marker_agresor,
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
    var connection = PostgreSQLConnection("worker.local.com", 5432, "appdb",
        username: "appuser", password: "strongpasswordapp", useSSL: false);
    String? id_app_flutter = await PlatformDeviceId.getDeviceId;
    Location location = new Location();
    LocationData _locationData;
    _locationData = await location.getLocation();

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

    radius = double.parse(radio.toString());
    Latvictima = double.parse(PosVictima[0][4].toString());
    Latagresor = double.parse(PosAgresor[0][3].toString());
    lonvictima = double.parse(PosVictima[0][3].toString());
    lonagresor = double.parse(PosAgresor[0][2].toString());

    var dt = DateTime.now();
    await connection.query(
        "INSERT INTO ubicacion_victima (id_victima,id_app_movil,longitud,latitud,fecha,hora) VALUES (@a,@b,@c,@d,@e,@f)",
        substitutionValues: {
          "a": "$id_victima",
          "b": "$id_app_flutter",
          "c": _locationData.longitude.toString(),
          "d": _locationData.latitude.toString(),
          "e": dt.month.toString() +
              '/' +
              dt.day.toString() +
              '/' +
              dt.year.toString(),
          "f": dt.hour.toString() +
              ':' +
              dt.minute.toString() +
              ':' +
              dt.second.toString()
        });

    await connection.close();
    //await Future.delayed(Duration(minutes: 1));
    Future.delayed(Duration(seconds: 1), () {
      // <-- Delay here
      setState(() {
        //Recibimos el mensaje del backend
        //reciveMessage();

        if (calculateDistance(Latvictima, lonvictima, Latagresor, lonagresor) -
                double.parse(radio.toString()) >
            10) {
          size_marker_agresor = 0;
          print(calculateDistance(
              Latvictima, lonvictima, Latagresor, lonagresor));
        } else {
          size_marker_agresor = 50;
          WidgetsFlutterBinding.ensureInitialized();
          NotificationService().initNotification();

          // NotificationService()
          //     .showNotification(title: 'ALERTA!', body: 'Agresor cerca!');
        }
      });
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * 1000 * asin(sqrt(a));
  }
/*
  void reciveMessage() {
    IOWebSocketChannel? channel;
    // We use a try - catch statement, because the connection might fail.
    try {
      // Connect to our backend.
      channel = IOWebSocketChannel.connect('ws://worker.local.com:4000');
      channel.stream.listen((event) async {
        // Just making sure it is not empty
        if (event!.isNotEmpty) {
          print(event);

          // Now only close the connection and we are done here!
          channel!.sink.close();
        }
      });
    } catch (e) {
      // If there is any error that might be because you need to use another connection.
      print("Error on connecting to websocket: " + e.toString());
    }
  }*/
}
