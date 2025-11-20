import 'dart:io';
import 'package:flutter/material.dart';
import '../models/journal_model.dart';
import '../services/journal_service.dart';

class JournalProvider with ChangeNotifier {
  List<Journal> _journals = [];
  bool _isLoading = false;

  List<Journal> get journals => _journals;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _calendarData = [];
  List<Map<String, dynamic>> get calendarData => _calendarData;

  final JournalService service = JournalService();

  // Update: Tambah parameter keyword (opsional)
  Future<void> fetchJournals({String? keyword}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _journals = await service.getJournals(keyword: keyword);
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addJournal(int moodId, String content, DateTime date, {File? image, String? musicLink, File? voice}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      await service.createJournal(
        moodId: moodId, 
        content: content, 
        date: dateString, 
        imageFile: image, 
        musicLink: musicLink,
        voiceFile: voice // <-- Kirim Voice
      ); 
      await fetchJournals(); 
      _isLoading = false;
      notifyListeners();
      return true; 
    } catch (e) {
      print("Error: $e");
      _isLoading = false;
      notifyListeners();
      return false; 
    }
  }

  // Update fungsi updateJournal (lakukan hal yang sama: tambah parameter voice)
  Future<bool> updateJournal(int id, int moodId, String content, DateTime date, {File? image, String? musicLink, File? voice}) async {
     // ... (logika sama, tinggal tambah parameter voice di service.updateJournal) ...
     // Biar hemat tempat, saya asumsikan kamu bisa nambahin parameter 'voice' kayak diatas ya!
     // Intinya: Provider terima voice -> Lempar ke Service
      _isLoading = true;
      notifyListeners();
      try {
        final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        await service.updateJournal(
          id: id, moodId: moodId, content: content, date: dateString, imageFile: image, musicLink: musicLink, 
          voiceFile: voice // <-- INI
        );
        await fetchJournals();
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
  }

  // Fungsi Baru: Delete
  Future<bool> deleteJournal(int id) async {
    try {
      await service.deleteJournal(id);
      // Hapus lokal biar kerasa cepet
      _journals.removeWhere((j) => j.id == id); 
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> fetchCalendarData() async {
    // Loading kecil ga perlu notify listener global biar ga kedip layarnya
    try {
      _calendarData = await service.getCalendarData();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
  
  // Helper: Ambil jurnal berdasarkan tanggal tertentu (untuk list di bawah kalender)
  List<Journal> getJournalsByDate(DateTime date) {
    final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _journals.where((j) => j.date == dateString).toList();
  }
}