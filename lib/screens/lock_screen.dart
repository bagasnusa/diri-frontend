import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/biometric_service.dart';
import '../utils/constants.dart';
import '../widgets/app_logo.dart';
import 'main_wrapper.dart'; // Halaman utama setelah lolos

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkAndAuth(); // Langsung minta sidik jari pas dibuka
  }

  Future<void> _checkAndAuth() async {
    setState(() => _isAuthenticating = true);
    final success = await _biometricService.authenticate();
    setState(() => _isAuthenticating = false);

    if (success) {
      // Lolos! Masuk ke Aplikasi
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Pakai warna gelap biar misterius
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 100, style: LogoStyle.soul),
            const SizedBox(height: 40),
            Text(
              "DIRI Terkunci",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            
            // Tombol kalau pop-up sidik jari hilang
            if (!_isAuthenticating)
              ElevatedButton.icon(
                onPressed: _checkAndAuth,
                icon: const Icon(Icons.fingerprint, color: Colors.white),
                label: const Text("Buka Gembok"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}