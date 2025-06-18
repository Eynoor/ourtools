import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000/api"; // Ganti dengan URL backend Laravel
  final String token; 

  ApiService(this.token);


  Map<String, String> get headers => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };


  Future<List<dynamic>> getRooms() async {
    final response = await http.get(Uri.parse("$baseUrl/rooms"), headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // List of rooms
    } else {
      throw Exception("Failed to fetch rooms: ${response.body}");
    }
  }

  /// POST: Create a new room
  Future<Map<String, dynamic>> createRoom(String roomNama, String roomLokasi) async {
    final body = json.encode({
      'room_nama': roomNama,
      'room_lokasi': roomLokasi,
    });

    final response = await http.post(Uri.parse("$baseUrl/rooms"), headers: headers, body: body);
    if (response.statusCode == 201) {
      return json.decode(response.body); // Room created
    } else {
      throw Exception("Failed to create room: ${response.body}");
    }
  }

  /// Joiin room menggunakan random code
  Future<Map<String, dynamic>> joinRoom(String randomCode) async {
    final body = json.encode({
      'random_code': randomCode,
    });

    final response = await http.post(Uri.parse("$baseUrl/rooms/join"), headers: headers, body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body); // Room joined
    } else {
      throw Exception("Failed to join room: ${response.body}");
    }
  }

}
