import 'package:flutter/material.dart';
import '../services/letter_service.dart';

class LetterProvider with ChangeNotifier {
  List<dynamic> _letters = [];
  bool _isLoading = false;

  List<dynamic> get letters => _letters;
  bool get isLoading => _isLoading;

  final LetterService _service = LetterService();

  Future<void> fetchLetters() async {
    _isLoading = true;
    notifyListeners();
    try {
      _letters = await _service.getLetters();
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendLetter(String message, DateTime openDate) async {
    _isLoading = true;
    notifyListeners();
    try {
      final dateString = "${openDate.year}-${openDate.month.toString().padLeft(2, '0')}-${openDate.day.toString().padLeft(2, '0')}";
      await _service.createLetter(message, dateString);
      await fetchLetters(); // Refresh list
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