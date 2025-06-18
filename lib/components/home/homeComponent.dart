import 'package:coba1/components/Borrow/borrowComponent.dart';
import 'package:coba1/screens/Borrow/borrowScreens.dart';
import 'package:coba1/screens/Borrow/borrowUserScreens.dart';
import 'package:coba1/screens/setting/Settingscreens.dart';
import 'package:flutter/material.dart';

class Homecomponent extends StatefulWidget {
  @override
  _HomecomponentState createState() => _HomecomponentState();
}

class _HomecomponentState extends State<Homecomponent> {
  // GlobalKey untuk mengakses ScaffoldState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Fungsi untuk menampilkan modal bottom sheet
  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.group_add),
                title: Text('Join Room'),
                onTap: () {
                  // Navigator.pop(context); // Tutup modal
                  // Tambahkan logika untuk Join Room di sini
                  
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EnterRoomDialog();
                    },
                  );
                  print('Join Room dipilih');
                },
              ),
              ListTile(
                leading: Icon(Icons.create),
                title: Text('Create Room'),
                onTap: () {
                
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CreateRoomDialog();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Tambahkan GlobalKey ke Scaffold
      // Drawer (Sidebar)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header Drawer
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Sidebar Header',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            // Menu 1
            ListTile(
              title: Text('Menu 1'),
              onTap: () {
                // Aksi saat Menu 1 dipilih
                Navigator.pop(context); // Tutup drawer
              },
            ),
            // Menu 2
            ListTile(
              title: Text('Menu 2'),
              onTap: () {
                // Aksi saat Menu 2 dipilih
                Navigator.pop(context); // Tutup drawer
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris untuk Ikon Atas
            Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ikon Menu (Kiri Atas)
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        // Buka drawer saat tombol menu ditekan
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                  // Ikon Tambah (Kanan Atas)
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: 30,
                      color: Colors.black,
                      onPressed: () {
                        // Tampilkan modal bottom sheet saat tombol plus ditekan
                        _showOptionsModal(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Widget lainnya di sini
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    onTap: () {
                      // Tampilkan modal bottom sheet saat card ditekan
                      //Navigator.pushNamed(context, Borrowscreens.routeName);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Borrowcomponent()));
                      print('Kartu "Gg Merah Putih" ditekan');
                    },
                    title: "Baseball prindapan",
                    subtitle: "G3 R4",
                  ),
                  SizedBox(height: 16),
                  _buildCard(
                    title: "Gg Merah Putih",
                    subtitle: "Rumah pak Totok",
                  ),
                  SizedBox(height: 16),
                  _buildCard(
                    title: "Kos Ms. Brow",
                    subtitle: "Pojok kanan kamar mandi deket kamar ms. brow",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, Settingscreens.routeName);
                },
                icon: const Icon(Icons.settings),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

Widget _buildCard(
    {required String title, required String subtitle, VoidCallback? onTap}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class CreateRoomDialog extends StatelessWidget {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Mengatur ukuran sesuai konten
          children: [
            Text(
              'Make your own room',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Input untuk Room Name
            TextField(
              controller: roomNameController,
              decoration: InputDecoration(
                labelText: 'Room name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Input untuk Location
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Tombol untuk Membuat Room
            ElevatedButton(
              onPressed: () {
                  Navigator.pushNamed(context, Borrowscreens.routeName);
                // Logika untuk membuat room
                print('Room Name: ${roomNameController.text}');
                print('Location: ${locationController.text}');
                // Navigator.pop(context); // Menutup dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Make Room',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnterRoomDialog extends StatelessWidget {
  final TextEditingController roomCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Room code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Input untuk Room Code
            TextField(
              controller: roomCodeController,
              decoration: InputDecoration(
                labelText: 'Enter code room',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Tombol ENTER
            ElevatedButton(
              onPressed: () {
                // Logika untuk memproses room code
                Navigator.pushNamed(context, BorrowUserscreens.routeName);
                print('Room Code: ${roomCodeController.text}');
                //Navigator.pop(context); // Menutup dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: Text(
                'ENTER',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
