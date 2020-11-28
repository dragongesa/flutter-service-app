import 'package:flutter/material.dart';
import 'package:service/pages/loginScreen.dart';

void main() {
  runApp(Service());
}

class Service extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "Montserrat"),
      title: "Revice",
      home: Login(),
    );
  }
}
