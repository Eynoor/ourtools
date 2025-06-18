import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://your-laravel-api-url.com/api'; // Ganti dengan URL API Laravel Anda

  /// Mendapatkan daftar semua barang
  Future<List<dynamic>> getAllBarang() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/barang'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']; // Mengembalikan daftar barang
      } else {
        throw Exception('Failed to fetch barang: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Menambahkan barang baru
  Future<void> createBarang({
    required String namaBarang,
    String? imageBase64,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/barang'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama_barang': namaBarang,
          'image': imageBase64, // Base64 string (optional)
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create barang: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Mendapatkan detail barang berdasarkan ID
  Future<Map<String, dynamic>> getBarangById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/barang/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to fetch barang: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Memperbarui barang berdasarkan ID
  Future<void> updateBarang({
    required int id,
    String? namaBarang,
    String? imageBase64,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/barang/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama_barang': namaBarang,
          'image': imageBase64, // Base64 string (optional)
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update barang: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Menghapus barang berdasarkan ID
  Future<void> deleteBarang(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/barang/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete barang: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
