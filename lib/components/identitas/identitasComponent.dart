import 'dart:typed_data';
import 'dart:convert';
import 'package:coba1/components/Camera/Camera.dart';
import 'package:coba1/components/identitas/api_service.dart'; // Import API service
import 'package:coba1/screens/Home/HomeScreens.dart';
import 'package:flutter/material.dart';

class Identitascomponent extends StatefulWidget {
  @override
  _IdentitascomponentState createState() => _IdentitascomponentState();
}

class _IdentitascomponentState extends State<Identitascomponent> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _faceVerificationImage;
  bool _isDataSent = false; // Flag to track if data has been sent

  // Submit Identitas to API
  Future<void> _submitIdentitas() async {
    final phoneNumber = _phoneNumberController.text;
    final isPhoneVerified = _otpController.text.isNotEmpty;
    final faceVerificationImage = _faceVerificationImage;

    if (faceVerificationImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil gambar terlebih dahulu!')),
      );
      return;
    }

    try {
      await identitas(phoneNumber, isPhoneVerified, faceVerificationImage);
      setState(() {
        _isDataSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identitas berhasil dikirim!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim identitas: $e')),
      );
    }
  }

  // Take a picture and encode to base64
  Future<void> _takePicture() async {
    final image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Camera()),
    );

    if (image != null && image is Uint8List && image.isNotEmpty) {
      print('Gambar berhasil diambil dengan panjang data: ${image.length}');
      setState(() {
        _faceVerificationImage = base64Encode(image);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar berhasil diambil!')),
      );
    } else {
      print('Gambar gagal diambil atau null.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada gambar yang diambil.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('User Verification'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Lengkapi data diri anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

          
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Phone Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: 'example: +62 xxxxxxxxxx',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      hintText: 'OTP',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'OTP dikirim ke: ${_phoneNumberController.text}'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            
            const Text(
              'Face Verification',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _faceVerificationImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(_faceVerificationImage!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : IconButton(
                      onPressed: _takePicture,
                      icon: const Icon(Icons.camera_alt_outlined, size: 100),
                    ),
            ),
            const Spacer(),

            // Submit Button
            ElevatedButton(
              onPressed: () async {
                if (_phoneNumberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nomor telepon belum diisi!')),
                  );
                  return;
                }

                if (_otpController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP belum diisi!')),
                  );
                  return;
                }

                if (_faceVerificationImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Gambar verifikasi wajah belum diambil!')),
                  );
                  return;
                }

                await _submitIdentitas();
                Navigator.pushNamed(context, Homescreens.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: _isDataSent
                  ? const Icon(Icons.check, color: Colors.white)
                  : const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
