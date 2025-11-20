import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'calendar_screen.dart'; 
import 'stats_screen.dart';    
import 'letters_screen.dart';  
import 'profile_screen.dart';  

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Kita gunakan List Widget biasa
  final List<Widget> _pages = [
    const HomeScreen(),
    const CalendarScreen(),
    const StatsScreen(),
    const LettersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // --- ANIMASI PINDAH TAB (MAGIC DISINI) ---
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500), // Durasi transisi (setengah detik)
        switchInCurve: Curves.easeOut, // Gerakan masuk halus
        switchOutCurve: Curves.easeIn, // Gerakan keluar halus
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Efek: Fade (Muncul pelan) + Slide dikit dari bawah
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05), // Mulai dari agak bawah dikit
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          // PENTING: Key ini biar Flutter tau halamannya beda
          key: ValueKey<int>(_currentIndex), 
          child: _pages[_currentIndex],
        ),
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color, 
          border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.primary.withOpacity(0.2),
            labelTextStyle: MaterialStateProperty.all(
              GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600), 
            ),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(color: AppColors.primary, size: 26);
              }
              return IconThemeData(color: theme.colorScheme.onSurface.withOpacity(0.6), size: 24);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: Colors.transparent,
            height: 70,
            elevation: 0,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: 'Jejak'),
              NavigationDestination(icon: Icon(Icons.show_chart_rounded), selectedIcon: Icon(Icons.ssid_chart_rounded), label: 'Wawasan'),
              NavigationDestination(icon: Icon(Icons.mail_outline_rounded), selectedIcon: Icon(Icons.mail_rounded), label: 'Surat'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Saya'),
            ],
          ),
        ),
      ),
    );
  }
}