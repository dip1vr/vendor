import 'package:flutter/material.dart';
import 'package:vendor_fixed/desh.dart';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black, // Set background color to black
        body: Desh(),
      ),
    );
  }
}