import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Butuh ini untuk decode data user
import '../services/auth_service.dart';
import '../models/user_model.dart'; // Import model baru
import 'dart:io';

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user; // Simpan data user disini
  bool _isLoading = false;

  String? get token => _token;
  User? get user => _user; // Getter untuk diambil UI
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  final AuthService _service = AuthService();

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.login(email, password);
      _token = response['access_token'];
      
      // Simpan User dari response API
      _user = User.fromJson(response['data']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      // Simpan data user ke HP biar kalau restart aplikasi tetep ingat
      await prefs.setString('user_data', json.encode(response['data']));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.register(name, email, password);
      _token = response['access_token'];
      _user = User.fromJson(response['data']); // Simpan user
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user_data', json.encode(response['data']));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cek login saat aplikasi baru dibuka
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    _token = prefs.getString('token');
    
    // Ambil data user yang tersimpan di HP
    if (prefs.containsKey('user_data')) {
      final userData = json.decode(prefs.getString('user_data')!);
      _user = User.fromJson(userData);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<bool> updateProfile(String name, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.updateProfile(name, imageFile);
      
      // UPDATE DATA USER DI MEMORI (PENTING!)
      // Kita timpa _user lama dengan data baru dari server
      _user = User.fromJson(response['data']);

      // UPDATE DATA DI STORAGE HP (Biar pas restart tetep update)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(response['data']));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}