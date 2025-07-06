import 'package:coba1/screens/opening/opening.dart';
import 'package:coba1/utils/session.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileImage = "https://via.placeholder.com/150"; // Default image URL.
  final Session session = Session();

  // Fungsi untuk mengganti foto profil.
  void _changeProfileImage() async {
    // Tambahkan logika untuk mengambil gambar dari kamera/galeri.
    setState(() {
      profileImage =
          "https://via.placeholder.com/150/FF5733"; // Ganti dengan path/image baru.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF012435),
      appBar: AppBar(
        backgroundColor: Color(0xFFEF9823),
        title: Text("Profil", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya.
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Gambar profil.
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(profileImage),
                ),
                // Tombol untuk mengganti foto.
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _changeProfileImage,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF012435),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Nama pengguna.
            Text(
              session.currentUsername?.toUpperCase() ?? "USER",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
            // Tombol logout.
            ElevatedButton.icon(
              onPressed: () {
                // Logika untuk logout.
                // Navigator.pop(context,
                // );
                Navigator.pushNamed(context, Openingscreen.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF012435),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text(
                "Log Out",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
