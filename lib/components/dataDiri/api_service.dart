import 'dart:convert';
import 'package:http/http.dart' as http;

// Base URL API
const String baseUrl = 'http://127.0.0.1:8000/api/data';

// Fungsi untuk mendapatkan semua data
Future<List<dynamic>> fetchData() async {
  try {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    throw Exception('Failed to load data: $e');
  }
}

// Fungsi untuk mendapatkan data berdasarkan ID
Future<Map<String, dynamic>> fetchDataById(int id) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data with ID: $id');
    }
  } catch (e) {
    throw Exception('Failed to load data with ID: $id: $e');
  }
}

// Fungsi untuk menyimpan data baru
Future<void> saveData(String namaAwal, String namaAkhir, String tanggalLahir,
    String alamat, String provinsi, String kabupaten, String kecamatan) async {
  try {
    final data = {
      'nama_awal': namaAwal,
      'nama_akhir': namaAkhir,
      'tanggal_lahir': tanggalLahir,
      'alamat': alamat,
      'provinsi': provinsi,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save data');
    }
  } catch (e) {
    throw Exception('Failed to save data: $e');
  }
}

// Fungsi untuk mengupdate data berdasarkan ID
Future<void> updateData(int id, String namaAwal, String namaAkhir, String tanggalLahir,
    String alamat, String provinsi, String kabupaten, String kecamatan) async {
  try {
    final data = {
      'nama_awal': namaAwal,
      'nama_akhir': namaAkhir,
      'tanggal_lahir': tanggalLahir,
      'alamat': alamat,
      'provinsi': provinsi,
      'kabupaten': kabupaten,
      'kecamatan': kecamatan
    };

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update data with ID: $id');
    }
  } catch (e) {
    throw Exception('Failed to update data with ID: $id: $e');
  }
}

// Fungsi untuk menghapus data berdasarkan ID
Future<void> deleteData(int id) async {
  try {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete data with ID: $id');
    }
  } catch (e) {
    throw Exception('Failed to delete data with ID: $id: $e');
  }
}
