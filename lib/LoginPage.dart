// ignore_for_file: avoid_print, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:mobile_app/Homepage.dart';
// ignore: depend_on_referenced_packages
import 'package:postgres/postgres.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:location/location.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String _title = 'Sistema de orden de alejamiento';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController ordenController = TextEditingController();
  TextEditingController cedulaController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Portal de inicio de sessión',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: ordenController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Número de orden',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: cedulaController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Cédula',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Contraseña',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                //forgot password screen
              },
              child: const Text(
                '¿Olvidó su contraseña?',
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: const Text('Loguearse'),
                  onPressed: () {
                    _operation();
                  },
                )),
          ],
        ));
  }

// uso de la funcion para conectarse a la DB
  Future _operation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    Future _location() async {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      //_locationData = await location.getLocation();
    }

    var connection = PostgreSQLConnection("10.0.0.93", 5432, "appdb",
        username: "appuser", password: "strongpasswordapp", useSSL: false);
    try {
      _location();
      _locationData = await location.getLocation();

      await connection.open();

      String id_victima = cedulaController.text;
      List<List<dynamic>> results_victima = await connection
          .query("select * from victima where id_victima = '$id_victima'");

      String id_orden = ordenController.text;
      List<List<dynamic>> results_orden = await connection
          .query("select * from orden where id_orden = '$id_orden'");

      String? id_app_flutter = await PlatformDeviceId.getDeviceId;
      List<List<dynamic>> caja_blanca = [];
      List<List<dynamic>> results_app = await connection.query(
          "select * from app_movil where id_app_movil = '$id_app_flutter'");
      //print(new List.from(results_victima)..addAll(results_orden));
      //print(results_orden[0][3].toString()); esto me da la distancia radio
      if (results_victima[0][0] == cedulaController.text &&
          results_victima[0][6] == passwordController.text &&
          results_orden[0][0] == ordenController.text) {
        var dt = DateTime.now();
        //print('PASASTE a la SGT PAG');
        if (results_app.toString() == caja_blanca.toString()) {
          await connection.transaction((ctx) async {
            await ctx.query(
                "INSERT INTO app_movil (id_app_movil,v_software) VALUES (@a,@b)",
                substitutionValues: {"a": "$id_app_flutter", "b": "v1.0"});
          });
        }
        await connection.transaction((ctx) async {
          await ctx.query(
              "INSERT INTO ubicacion_victima (id_victima,id_app_movil,longitud,latitud,fecha,hora) VALUES (@a,@b,@c,@d,@e,@f)",
              substitutionValues: {
                "a": cedulaController.text,
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
        });

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              victima: new List.from(results_victima)..addAll(results_orden),
            ),
          ),
        );
      } else {
        print('Loggin failed');
      }
    } catch (e) {
      print("Loggin failed por el try");
    }
  }
}
