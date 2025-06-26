import 'dart:typed_data';
import 'dart:convert';
import 'package:coba1/components/Camera/Camera.dart';
import 'package:coba1/components/identitas/api_service.dart';
import 'package:coba1/screens/Home/HomeScreens.dart';
import 'package:coba1/utils/constants.dart';
import 'package:flutter/material.dart';

class Identitascomponent extends StatefulWidget {
  @override
  _IdentitascomponentState createState() => _IdentitascomponentState();
}

class _IdentitascomponentState extends State<Identitascomponent> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl   = TextEditingController();
  String? _faceImg;
  bool _isSent = false;

  Future<void> _submitIdentitas() async {
    final phone = _phoneCtrl.text;
    final verified = _otpCtrl.text.isNotEmpty;
    if (_faceImg == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ambil gambar dulu!')));
      return;
    }
    try {
      await identitas(phone, verified, _faceImg!);
      setState(() => _isSent = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Terkirim!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _takePicture() async {
    final img = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Camera()),
    );
    if (img is Uint8List && img.isNotEmpty) {
      setState(() => _faceImg = base64Encode(img));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gambar diambil!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(128, 8, 16, 109),
      appBar: AppBar(
        title: const Text('User Verification',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  'Lengkapi data diri anda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // PHONE NUMBER
              const Text('Phone Number',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+62 xxxxxxxxxx',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // OTP + SEND
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'OTP',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'OTP dikirim ke: ${_phoneCtrl.text}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Send',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),

              // VERIFIKASI BUTTON DI SINI
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_otpCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Masukkan OTP terlebih dahulu')));
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('OTP "${_otpCtrl.text}" terverifikasi')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Verifikasi',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),

              // FACE VERIFICATION
              const Text('Face Verification',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _faceImg != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(_faceImg!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: IconButton(
                          onPressed: _takePicture,
                          icon: const Icon(Icons.camera_alt_outlined),
                          color: Colors.grey[700],
                          iconSize: 48,
                        ),
                      ),
              ),
              const SizedBox(height: 32),

              // NEXT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_phoneCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Nomor telepon belum diisi!')),
                      );
                      return;
                    }
                    if (_otpCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP belum diisi!')),
                      );
                      return;
                    }
                    if (_faceImg == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Gambar verifikasi wajah belum diambil!')),
                      );
                      return;
                    }
                    await _submitIdentitas();
                    Navigator.pushNamed(context, Homescreens.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _isSent
                      ? const Icon(Icons.check, color: Colors.white)
                      : const Text('Next',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }
}