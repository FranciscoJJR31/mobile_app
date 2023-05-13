import 'package:flutter/material.dart';
import 'package:mobile_app/LoginPage.dart';
import 'package:mobile_app/local_notice_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      );
}
