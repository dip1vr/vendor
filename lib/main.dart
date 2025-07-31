import 'package:flutter/material.dart';
import 'package:vendor_fixed/desh.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Order Page'),
        ),
        body: Center(
          child: Desh(),
        ),
      ),
    );
  }
}