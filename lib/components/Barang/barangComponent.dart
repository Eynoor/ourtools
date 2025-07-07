import 'package:coba1/components/Camera/Camera.dart';
//import 'package:coba1/services/api_service.dart'; // Pastikan path ini sesuai
import 'package:coba1/screens/Borrow/borrowScreens.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk mengelola base64 encoding
import 'package:image/image.dart' as img; // Import package image
import 'dart:typed_data';
import 'package:coba1/utils/db_helper.dart'; // Ganti ApiService dengan DBHelper

class Barangcomponent extends StatefulWidget {
  final int roomId;
  Barangcomponent({required this.roomId});

  @override
  _BarangcomponentState createState() => _BarangcomponentState();
}

class _BarangcomponentState extends State<Barangcomponent> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemStockController = TextEditingController();
  final DBHelper _dbHelper = DBHelper(); // Gunakan DBHelper
  Uint8List?
      _selectedImageBytes; // Untuk menyimpan gambar yang dipilih/dicapture dalam bentuk bytes
  bool _isLoading = false; // Untuk menunjukkan loading state

  // Fungsi untuk memilih gambar (opsional, bisa dihubungkan dengan Camera.dart)
  void _selectImage(Uint8List? imageBytes) {
    setState(() {
      _selectedImageBytes = imageBytes;
    });
  }

  // Fungsi untuk mengubah ukuran gambar agar tidak terlalu besar
  Future<Uint8List?> _resizeImage(Uint8List? imageBytes) async {
    if (imageBytes == null) return null;

    // Decode gambar dari bytes
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // Ubah ukuran gambar ke lebar maksimum 800px (aspek rasio terjaga)
    img.Image resizedImage = img.copyResize(image, width: 800);

    // Encode kembali ke format JPG dengan kualitas 85%
    // Ini akan mengurangi ukuran file secara signifikan
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
  }

  // Fungsi untuk mengirim data barang ke API
  Future<void> _addBarang() async {
    final namaBarang = _itemNameController.text.trim();
    final stockText = _itemStockController.text.trim();

    if (namaBarang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama barang tidak boleh kosong')),
      );
      return;
    }
    final int stock = int.tryParse(stockText) ?? 0;
    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah stok harus lebih dari 0')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      final resizedImageBytes = await _resizeImage(_selectedImageBytes);
      print('Insert barang dengan room_id: [33m[1m[4m${widget.roomId}[0m');
      // Simpan barang ke database lokal
      final result = await _dbHelper.insertBarang({
        'nama_barang': namaBarang,
        'image': resizedImageBytes,
        'stock': stock,
        'room_id': widget.roomId,
      });
      print('Insert result: $result');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barang berhasil ditambahkan')),
      );

      // Kembali ke halaman sebelumnya dan kirim sinyal 'true' bahwa ada data baru
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, stack) {
      print('Error saat menambahkan barang: $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan barang: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Selesai loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF012435),
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
              'Jumlah Stok',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _itemStockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan jumlah stok awal',
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
                final Uint8List? selectedImageBytes = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Camera()),
                );
                _selectImage(selectedImageBytes);
              },
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _selectedImageBytes != null
                      ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
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
                  backgroundColor: Color(0xFF012435),
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
