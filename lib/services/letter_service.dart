import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class LetterService {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // Ambil Semua Surat
  Future<List<dynamic>> getLetters() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${AppUrls.baseUrl}/letters'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Gagal mengambil surat');
    }
  }

  // Kirim Surat Baru
  Future<void> createLetter(String message, String openDate) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${AppUrls.baseUrl}/letters'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: {
        'message': message,
        'open_date': openDate, // Format YYYY-MM-DD
      },
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal mengirim surat: ${response.body}');
    }
  }
}