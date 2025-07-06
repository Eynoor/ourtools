import 'package:flutter/material.dart';

class Donatecomponent extends StatefulWidget {
  @override
  _DonateComponentState createState() => _DonateComponentState();
}

class _DonateComponentState extends State<Donatecomponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF012435), // Warna biru gelap latar belakang
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon atau Gambar Tangan
                Icon(
                  Icons.handshake, // Gunakan ikon bawaan Flutter
                  size: 100,
                  color: Color(0xFFEF9823),
                ),

                SizedBox(height: 16),

                // Text "Support Us"
                Text(
                  'Support Us',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 8),

                // Text "Dana"
                Text(
                  'Dana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 24),

                // Tombol Nomor
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan aksi ketika tombol diklik
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEF9823),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    '+62 8887771409',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Tombol Kembali
      appBar: AppBar(
        backgroundColor: Color(0xFFEF9823),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke layar sebelumnya
          },
        ),
      ),
    );
  }
}
