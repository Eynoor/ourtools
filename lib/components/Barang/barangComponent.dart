import 'package:coba1/components/Camera/Camera.dart';
//import 'package:coba1/services/api_service.dart'; // Pastikan path ini sesuai
import 'package:coba1/screens/Borrow/borrowScreens.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk mengelola base64 encoding
import 'dart:io'; // Untuk File
import 'api_service.dart';

class Barangcomponent extends StatefulWidget {
  @override
  _BarangcomponentState createState() => _BarangcomponentState();
}

class _BarangcomponentState extends State<Barangcomponent> {
  final TextEditingController _itemNameController = TextEditingController();
  final ApiService _apiService = ApiService();
  File? _selectedImage; // Untuk menyimpan gambar yang dipilih/dicapture
  bool _isLoading = false; // Untuk menunjukkan loading state

  // Fungsi untuk memilih gambar (opsional, bisa dihubungkan dengan Camera.dart)
  void _selectImage(File? image) {
    setState(() {
      _selectedImage = image;
    });
  }

  // Fungsi untuk mengubah File ke Base64
  String? _convertToBase64(File? file) {
    if (file == null) return null;
    final bytes = file.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Fungsi untuk mengirim data barang ke API
  Future<void> _addBarang() async {
    final namaBarang = _itemNameController.text.trim();
    if (namaBarang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama barang tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      // Mengonversi gambar ke Base64 jika ada
      final imageBase64 = _convertToBase64(_selectedImage);

      // Memanggil API untuk menambahkan barang
      await _apiService.createBarang(
        namaBarang: namaBarang,
        imageBase64: imageBase64,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barang berhasil ditambahkan')),
      );

      // Reset form setelah sukses
      _itemNameController.clear();
      setState(() {
        _selectedImage = null;
      });

      // Navigasi ke BorrowScreens
      Navigator.pushNamed(context, Borrowscreens.routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan barang: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Selesai loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama barang',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan nama barang',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Foto barang',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                // Navigasi ke kamera atau file picker
                final File? selectedImage = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Camera()),
                );
                _selectImage(selectedImage);
              },
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addBarang,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
