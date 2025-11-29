import 'package:flutter/material.dart';
import 'laporan.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const LaporanPage(),
      },
    );
  }
}
