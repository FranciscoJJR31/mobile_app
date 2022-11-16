import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
//const HomePage({super.key});
  String orden;
  HomePage({super.key, required this.orden});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bienvenido ' + orden),
        ),
        body: Center(
          child: Text(orden, style: TextStyle(fontSize: 50)),
        ),
      ),
    );
  }
}
