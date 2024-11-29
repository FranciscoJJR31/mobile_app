import 'dart:ffi';

//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'nav-drawer.dart';

// ignore: camel_case_types
class informacionPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _informacionPageState createState() => _informacionPageState();
}

// ignore: camel_case_types
class _informacionPageState extends State<informacionPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Flutter',
      home: Scaffold(
        drawer: const NavDrawer(),
        appBar: AppBar(
          title: const Text('Mapa'),
        ),
        body: Center(
          child: Scaffold(
            body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 70.0,
                      backgroundImage: AssetImage('assets/images/pgr.jpg'),
                    ),
                    const Center(
                      child: Text(
                        'Procuraduría General de la República Dominicana',
                        style: TextStyle(
                          fontFamily: 'Anton',
                          fontSize: 30.0,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      'Linea de atención al cliente',
                      style: TextStyle(
                        fontFamily: 'Anton',
                        fontSize: 14.0,
                        color: Colors.deepPurpleAccent,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                      width: 150.0,
                      child: Divider(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 25.0),
                      child: ListTile(
                        onTap: _launchURL,
                        leading: const Icon(
                          Icons.phone,
                          color: Colors.black,
                        ),
                        title: const Text(
                          '809-533-3522',
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Linea de emergencia',
                      style: TextStyle(
                        fontFamily: 'Anton',
                        fontSize: 14.0,
                        color: Colors.deepPurpleAccent,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                      width: 150.0,
                      child: Divider(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 25.0),
                      child: ListTile(
                        onTap: _launch911,
                        leading: const Icon(
                          Icons.phone,
                          color: Colors.black,
                        ),
                        title: const Text(
                          '911',
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _back() async {
    return true;
  }

  _launchURL() async {
    const url = 'tel:8095333522';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No inicia la llamada';
    }
  }

  _launch911() async {
    const url = 'tel:911';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No inicia la llamada';
    }
  }
}
