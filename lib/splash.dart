import 'package:sumtime/login.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const String logoAssetPath = 'assets/logoanimate.gif'; 
  final Duration splashDuration = const Duration(seconds: 3);
  
  @override
  void initState() {
    super.initState();
    //Future.delayed karena pemuatan asset sangat cepat
    Future.delayed(splashDuration, () {
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => LoginPage())
        ); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDD0303), 
      body: Center(
        child: 
            Image.asset(
              logoAssetPath,
              width: 250, 
              height: 250,
              // Jika file asset tidak ditemukan (error), tampilkan ikon
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported, 
                  color: Colors.red,
                  size: 100,
                );
              },
            ),
      ),
    );
  }
}