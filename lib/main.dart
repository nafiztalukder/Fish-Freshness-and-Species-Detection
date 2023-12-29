import 'package:fish_detection/home.dart';
import 'package:flutter/material.dart';


// ignore: prefer_const_constructors
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.purple),
      debugShowCheckedModeBanner: false,
      // ignore: prefer_const_constructors
      home: Home(),
    );
  }
}