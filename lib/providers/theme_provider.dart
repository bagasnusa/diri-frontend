import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Default: Dark Mode (True)
  bool _isDark = true;

  bool get isDark => _isDark;

  // Constructor: Cek memori HP saat aplikasi nyala
  ThemeProvider() {
    _loadFromPrefs();
  }

  // Ganti Tema
  void toggleTheme() {
    _isDark = !_isDark;
    _saveToPrefs();
    notifyListeners();
  }

  // Simpan ke HP
  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }

  // Baca dari HP
  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? true; // Default True (Dark)
    notifyListeners();
  }
}