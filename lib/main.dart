import 'package:flutter/material.dart';
import 'splash.dart';
import 'login.dart';
import 'beranda.dart';

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
      // Atur route ke login dan beranda
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const BerandaPage(),
      },
    );
  }
}
