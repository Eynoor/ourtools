import 'package:coba1/components/Camera/Camera.dart';
//import 'package:coba1/services/api_service.dart'; // Pastikan path ini sesuai
import 'package:coba1/screens/Borrow/borrowScreens.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Untuk mengelola base64 encoding
import 'package:image/image.dart' as img; // Import package image
import 'dart:typed_data';
import 'package:coba1/utils/db_helper.dart'; // Ganti ApiService dengan DBHelper
import 'package:flutter/services.dart';

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

  // Fungsi untuk menampilkan custom snackbar
  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Fungsi untuk mengubah ukuran gambar agar tidak terlalu besar
  Future<Uint8List?> _resizeImage(Uint8List? imageBytes) async {
    if (imageBytes == null || imageBytes.isEmpty) return null;

    try {
      // Decode gambar dari bytes
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null || image.width <= 0 || image.height <= 0) {
        return null;
      }

      // Ubah ukuran gambar ke lebar maksimum 800px (aspek rasio terjaga)
      img.Image resizedImage = img.copyResize(image, width: 800);

      // Encode kembali ke format JPG dengan kualitas 85%
      // Ini akan mengurangi ukuran file secara signifikan
      return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));
    } catch (e) {
      print("Error resizing image: $e");
      return null;
    }
  }

  // Fungsi untuk mengirim data barang ke API
  Future<void> _addBarang() async {
    final namaBarang = _itemNameController.text.trim();
    final stockText = _itemStockController.text.trim();

    if (namaBarang.isEmpty) {
      _showCustomSnackBar('Nama barang tidak boleh kosong', isError: true);
      return;
    }
    final int stock = int.tryParse(stockText) ?? 0;
    if (stock <= 0) {
      _showCustomSnackBar('Jumlah stok harus lebih dari 0', isError: true);
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

      _showCustomSnackBar('Barang berhasil ditambahkan!');

      // Kembali ke halaman sebelumnya dan kirim sinyal 'true' bahwa ada data baru
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, stack) {
      print('Error saat menambahkan barang: $e');
      print(stack);
      _showCustomSnackBar('Gagal menambahkan barang: $e', isError: true);
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF012435),
              Color(0xFF012435).withOpacity(0.9),
              Color(0xFF012435).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar dengan animasi
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Barang',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Kelola inventaris dengan mudah',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content Area
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Indicator bar
                          Center(
                            child: Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFEF9823),
                                    Color(0xFFD8860B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          
                          // Nama Barang Field
                          _buildInputSection(
                            title: 'Nama Barang',
                            icon: Icons.inventory_2_outlined,
                            child: _buildTextField(
                              controller: _itemNameController,
                              hintText: 'Masukkan nama barang',
                              prefixIcon: Icons.label_outline,
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Stok Field
                          _buildInputSection(
                            title: 'Jumlah Stok',
                            icon: Icons.numbers_outlined,
                            child: _buildTextField(
                              controller: _itemStockController,
                              hintText: 'Masukkan jumlah stok',
                              prefixIcon: Icons.inventory_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Photo Section
                          _buildInputSection(
                            title: 'Foto Barang',
                            icon: Icons.camera_alt_outlined,
                            child: _buildPhotoSelector(),
                          ),
                          
                          SizedBox(height: 40),
                          
                          // Submit Button
                          _buildSubmitButton(),
                          
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF012435).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Color(0xFF012435),
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(prefixIcon, color: Color(0xFF012435)),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF012435), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPhotoSelector() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final Uint8List? selectedImageBytes = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Camera()),
        );
        _selectImage(selectedImageBytes);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedImageBytes != null 
                ? Color(0xFFEF9823) 
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _selectedImageBytes != null
              ? Stack(
                  children: [
                    Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  color: Colors.grey[50],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF012435).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: Color(0xFF012435),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tap untuk mengambil foto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF012435),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Foto akan membantu identifikasi barang',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Color(0xFFEF9823),
            Color(0xFFD8860B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFEF9823).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () {
          HapticFeedback.mediumImpact();
          _addBarang();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Menambahkan...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Tambah Barang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
