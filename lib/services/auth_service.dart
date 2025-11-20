import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'dart:io';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppUrls.baseUrl}/login'),
        body: {'email': email, 'password': password},
      );

      // Jika respon OK (200), kita decode JSON-nya
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Jika gagal (password salah dll)
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('${AppUrls.baseUrl}/register');
    
    // CCTV 1: Lapor mau kirim kemana
    print("Mencoba connect ke: $url"); 
    
    try {
      final response = await http.post(
        url,
        body: {'name': name, 'email': email, 'password': password},
        headers: {"Accept": "application/json"}, // Tambahkan header ini biar Laravel ngerti
      );

      // CCTV 2: Lapor balasan server
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Jika error dari Laravel (misal email kembar)
        throw Exception('Gagal: ${response.body}');
      }
    } catch (e) {
      // CCTV 3: Lapor kalau error koneksi
      print("ERROR KONEKSI: $e");
      throw Exception('Error Koneksi: $e');
    }
  }
  Future<Map<String, dynamic>> updateProfile(String name, File? imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Gunakan Multipart Request (PENTING!)
    var request = http.MultipartRequest('POST', Uri.parse('${AppUrls.baseUrl}/update-profile'));
    
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['name'] = name;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal update profil: ${response.body}');
    }
  }
}