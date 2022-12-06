import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
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
        appBar: AppBar(
          title: Text('Bienvenido ' + victima[0][0]),
        ),
        body: Center(
          child: Text(victima[0][1], style: TextStyle(fontSize: 50)),
        ),
      ),
    );
  }
}
