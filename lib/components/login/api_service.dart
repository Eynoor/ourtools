import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; 

  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
          'token': data['token'], 
        };
      } else if (response.statusCode == 401) {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['error'],
        };
      } else {
        // ignore: unused_local_variable
        final error = jsonDecode(response.body);
        throw Exception('Terjadi kesalahan pada server');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  
  Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse('$baseUrl/profile');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch profile',
        };
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
