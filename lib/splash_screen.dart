import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi dibuat lebih cepat dan smooth (khas aplikasi modern)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Animasi Fade In (Muncul perlahan)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Animasi Scale (Membesar sedikit dengan sangat halus)
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Timer dipersingkat jadi 2.5 detik (Best practice aplikasi modern jangan terlalu lama)
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          // Pindah ke halaman Home dengan efek Fade (Bukan geser) biar kerasa premium
          pageBuilder: (_, __, ___) => const MainHomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Background putih bersih mengikuti Home Page
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO ICON (Ganti dengan asset gambar logo lu nanti jika ada)
                const Icon(
                  Icons.checkroom_rounded,
                  size: 70,
                  color: Colors.black, // Logo hitam minimalis
                ),
                const SizedBox(height: 16),

                // NAMA BRAND
                const Text(
                  'COSVORIA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black, // Teks hitam solid
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 6),

                // TAGLINE SANGAT KECIL (Opsional, tapi ngasih kesan eksklusif)
                Text(
                  'C O S P L A Y   R E N T A L',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[400],
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
