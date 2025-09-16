import 'package:flutter/material.dart';
import 'package:moneyswap/homepage.dart';
import 'package:moneyswap/login.dart';
import 'homepage.dart'; // استدعاء الهوم بيدج

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // يشيل علامة debug
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // الصفحة الأساسية
    );
  }
}
