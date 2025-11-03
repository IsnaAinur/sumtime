import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const BerandaPage(),
      routes: {
        '/beranda': (context) => const BerandaPage(),
      },
    );
  }
}