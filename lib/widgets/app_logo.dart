import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

enum LogoStyle { bloom, soul, spark }

class AppLogo extends StatelessWidget {
  final double size;
  final bool withText;
  final LogoStyle style;

  const AppLogo({
    super.key,
    this.size = 100, 
    this.withText = true,
    this.style = LogoStyle.soul, 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- BAGIAN ICON ---
        SizedBox(
          width: size,
          height: size,
          child: _buildIcon(),
        ),
        
        // --- BAGIAN TEKS ---
        if (withText) ...[
          const SizedBox(height: 16),
          Text(
            'DIRi',
            style: GoogleFonts.poppins(
              fontSize: size * 0.3, 
              fontWeight: FontWeight.w600,
              letterSpacing: 2, 
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Segalanya tentang Perasaan & Diri ini.",
            style: GoogleFonts.lato(
              fontSize: size * 0.12,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIcon() {
    switch (style) {
      case LogoStyle.bloom:
        return _buildBloomLogo();
      case LogoStyle.soul:
        return _buildSoulLogo();
      case LogoStyle.spark:
        return _buildSparkLogo();
    }
  }

  Widget _buildBloomLogo() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.2), 
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ]
      ),
      child: Center(
        child: Icon(
          Icons.spa_rounded, 
          size: size * 0.6,
          color: AppColors.accent,
        ),
      ),
    );
  }

  // OPSI 2: SOUL (GLOW RESTORED & REFINED!) ✨
  Widget _buildSoulLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Lingkaran Luar (Aura Hangat)
        Transform.rotate(
          angle: -0.2,
          child: Container(
            width: size,
            height: size * 0.9,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size * 0.4),
              // INI DIA CAHAYANYA!
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25), // Glow lembut
                  blurRadius: 20, // Pendaran luas
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
        // Lingkaran Dalam (Inti)
        Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: BoxDecoration(
            color: AppColors.primary, 
            shape: BoxShape.circle,
            // Shadow Inti agar terlihat timbul (3D)
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.fingerprint, 
            color: Colors.white.withOpacity(0.9),
            size: size * 0.35,
          ),
        ),
      ],
    );
  }

  Widget _buildSparkLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8D6E63), Color(0xFFD7CCC8)],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D6E63).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Center(
        child: Icon(Icons.auto_awesome, size: size * 0.5, color: Colors.white),
      ),
    );
  }
}