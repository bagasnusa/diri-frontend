import 'package:diri_v1/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup Animasi (Durasi 2 Detik)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Efek Muncul (Fade In)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Efek Membesar Dikit (Scale Up) biar dramatis
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Mulai Animasi
    _controller.forward();

    // Timer pindah halaman
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Tunggu 3 detik (biar logo sempat dinikmati)
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Pindah ke Penjaga Pintu (AuthCheckWrapper) dengan animasi Fade
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthCheckWrapper(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800), // Transisi halus
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kita paksa background gelap biar glow-nya pop-up!
    return Scaffold(
      backgroundColor: AppColors.background, 
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO KITA YANG BERSINAR ✨
                const AppLogo(
                  size: 120, 
                  style: LogoStyle.soul, 
                  withText: false
                ),
                const SizedBox(height: 24),
                // TEKS DIRI
                Text(
                  'DIRI',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8, // Spasi lebar biar sinematik
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ruang amanmu.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.white54,
                    letterSpacing: 2,
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