import 'package:flutter/material.dart';
import 'package:mobile_app/Homepage.dart';
import 'package:postgres/postgres.dart';

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
  TextEditingController nameController = TextEditingController();
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
                controller: nameController,
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
//                    print(ordenController.text);
//                    print(nameController.text);
//                    print(passwordController.text);
                    operation();
                  },
                )),
          ],
        ));
  }

// uso de la funcion para conectarse a la DB
  Future operation() async {
    var connection = PostgreSQLConnection("10.0.0.85", 5432, "appdb",
        username: "appuser", password: "strongpasswordapp", useSSL: false);
    try {
      await connection.open();
      //print("Connectada a la DB");
      List<List<dynamic>> results =
          await connection.query("select * from phonebook");
      print(results[0][1]);
      if (results[0][1] == ordenController.text) {
        //print('PASASTE a la SGT PAG');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              orden: results[0][1].toString(),
            ),
          ),
        );
      } else {
        print('Tu la MACASTE VIEJITO');
      }
    } catch (e) {
      print("error al conectar en la DB");
    }
  }
}
