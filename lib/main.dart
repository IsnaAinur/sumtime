import 'package:flutter/material.dart';
import 'login.dart';
import 'beranda.dart';
import 'history_pesanan.dart';
import 'profile.dart';
import 'admin/order_page.dart';
import 'admin/laporan.dart';

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
        '/beranda': (context) => const BerandaPage(),
        '/history': (context) => const HistoryPesananPage(),
        '/profile': (context) => const ProfilePage(),
        '/order': (context) => const OrderPage(),
        '/laporan': (context) => const LaporanPage(),
      },
    );
  }
}
