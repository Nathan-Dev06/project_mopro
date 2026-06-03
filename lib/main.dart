import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Hanya butuh import splash screen saja

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosvoria Demo',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Aplikasi dimulai dari sini
    );
  }
}
