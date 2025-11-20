import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/journal_model.dart';

class JournalService {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // Update: Terima parameter keyword untuk search
  Future<List<Journal>> getJournals({String? keyword}) async {
    final token = await _getToken();
    
    String url = '${AppUrls.baseUrl}/journals';
    if (keyword != null && keyword.isNotEmpty) {
      url += '?keyword=$keyword';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((json) => Journal.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil jurnal');
    }
  }

  Future<List<Mood>> getMoods() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${AppUrls.baseUrl}/moods'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((json) => Mood.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil mood');
    }
  }

  // Create
  Future<void> createJournal({
    required int moodId,
    required String content,
    required String date,
    File? imageFile,
    String? musicLink,
    File? voiceFile, // <--- PARAMETER BARU
  }) async {
    final token = await _getToken();
    var request = http.MultipartRequest('POST', Uri.parse('${AppUrls.baseUrl}/journals'));
    
    request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    request.fields['mood_id'] = moodId.toString();
    request.fields['content'] = content;
    request.fields['date'] = date;
    if (musicLink != null) request.fields['music_link'] = musicLink;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    
    // LOGIKA VOICE NOTE
    if (voiceFile != null) {
      request.files.add(await http.MultipartFile.fromPath('voice', voiceFile.path));
    }

    var response = await request.send();
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal upload');
    }
  }

  // 2. Update UPDATE JOURNAL
  Future<void> updateJournal({
    required int id,
    required int moodId,
    required String content,
    required String date,
    File? imageFile,
    String? musicLink,
    File? voiceFile, // <--- PARAMETER BARU
  }) async {
    final token = await _getToken();
    final url = Uri.parse('${AppUrls.baseUrl}/journals/$id');
    var request = http.MultipartRequest('POST', url); // Ingat POST, bukan PUT
    
    request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    
    request.fields['mood_id'] = moodId.toString();
    request.fields['content'] = content;
    request.fields['date'] = date;
    if (musicLink != null) request.fields['music_link'] = musicLink;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }
    
    // LOGIKA VOICE NOTE
    if (voiceFile != null) {
      request.files.add(await http.MultipartFile.fromPath('voice', voiceFile.path));
    }

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Gagal update');
    }
  }

  // Delete (Hapus)
  Future<void> deleteJournal(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${AppUrls.baseUrl}/journals/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus');
    }
  }

  Future<List<Map<String, dynamic>>> getCalendarData() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${AppUrls.baseUrl}/journals/calendar'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Kita return List of Map biasa, karena strukturnya beda dikit sama Model Journal
      return List<Map<String, dynamic>>.from(json.decode(response.body)['data']);
    } else {
      throw Exception('Gagal ambil data kalender');
    }
  }
}