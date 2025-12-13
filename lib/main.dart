import 'package:flutter/material.dart';
import 'login.dart';
import 'admin/order_page.dart';

void main() {
  runApp(const SumTimeApp());
}

class SumTimeApp extends StatelessWidget {
  const SumTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SumTime',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // Atur route ke login dan order page
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/order': (context) => const OrderPage(),
      },
    );
  }
}
