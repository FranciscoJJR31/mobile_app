import 'package:flutter/material.dart';
import 'package:mobile_app/Homepage.dart';
import 'package:postgres/postgres.dart';
import 'package:platform_device_id/platform_device_id.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String _title = 'Sistema de orden de alejamiento';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    var connection = PostgreSQLConnection("10.0.0.85", 5432, "appdb",
        username: "appuser", password: "strongpasswordapp", useSSL: false);
    try {
      await connection.open();
      //print("Connectada a la DB");
      String id_victima = cedulaController.text;
      List<List<dynamic>> results_victima = await connection
          .query("select * from victima where id_victima = '$id_victima'");

      // String id_orden = ordenController.text;
      // List<List<dynamic>> results_orden = await connection
      //     .query("select * from orden where id_orden = '$id_orden'");

      String? id_app_flutter = await PlatformDeviceId.getDeviceId;
      List<List<dynamic>> caja_blanca = [];
      List<List<dynamic>> results_app = await connection.query(
          "select * from app_movil where id_app_movil = '$id_app_flutter'");
      // print("select * from app_movi where id_app_movil = '$id_app_flutter'");
      print(caja_blanca.toString());
      if (results_victima[0][0] == cedulaController.text &&
          results_victima[0][6] == passwordController.text) {
        //print('PASASTE a la SGT PAG');
        if (results_app.toString() == caja_blanca.toString()) {
          await connection.transaction((ctx) async {
            await ctx.query(
                "INSERT INTO app_movil (id_app_movil,v_software) VALUES (@a,@b)",
                substitutionValues: {"a": "$id_app_flutter", "b": "v1.0"});
          });
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              //orden: results[0][1].toString(),
              victima: results_victima,
            ),
          ),
        );
      } else {
        print('Loggin failed');
      }
    } catch (e) {
      print("Loggin failed");
    }
  }
}
