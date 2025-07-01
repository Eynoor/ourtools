import 'package:coba1/components/Borrow/borrowComponent.dart';
import 'package:coba1/screens/Borrow/borrowScreens.dart';
import 'package:coba1/screens/Borrow/borrowUserScreens.dart';
import 'package:coba1/screens/setting/Settingscreens.dart';
import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';

class Homecomponent extends StatefulWidget {
  @override
  _HomecomponentState createState() => _HomecomponentState();
}

class _HomecomponentState extends State<Homecomponent> {
  // GlobalKey untuk mengakses ScaffoldState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List untuk menyimpan data room
  List<Map<String, String>> rooms = [];
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final List<Map<String, dynamic>> roomsFromDB = await _dbHelper.getRooms();
    if (roomsFromDB.isNotEmpty) {
      setState(() {
        rooms = roomsFromDB
            .map((e) => {'title': e['title'] as String, 'subtitle': e['subtitle'] as String})
            .toList();
      });
    } else {
      setState(() {
        rooms = [
          {
            'title': 'Baseball prindapan',
            'subtitle': 'G3 R4',
          },
          {
            'title': 'Gg Merah Putih',
            'subtitle': 'Rumah pak Totok',
          },
          {
            'title': 'Kos Ms. Brow',
            'subtitle': 'Pojok kanan kamar mandi deket kamar ms. brow',
          },
        ];
      });
      // Save default rooms to DB
      for (var room in rooms) {
        await _dbHelper.insertRoom(room);
      }
    }
  }

  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 180,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.group_add),
                  title: Text('Join Room'),
                  onTap: () {
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
                    Navigator.pop(context); // Tutup modal bottom sheet sebelum showDialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CreateRoomDialog(
                          onCreate: (String title, String subtitle) async {
                            print('Inserting room: $title, $subtitle');
                            await _dbHelper.insertRoom({'title': title, 'subtitle': subtitle});
                            await _loadRooms();
                            Navigator.pop(context); // Tutup dialog setelah membuat room
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
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
                color: Color(0xFFFF7643),
              ),
              child: Text(
                'Sidebar Header',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
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
                  bottom: BorderSide(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 1),
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
                      color: const Color.fromARGB(255, 255, 255, 255),
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
                      color: const Color.fromARGB(255, 255, 255, 255),
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
                children: rooms.map((room) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildCard(
                      title: room['title'] ?? '',
                      subtitle: room['subtitle'] ?? '',
                      onTap: () {
                        print('Room card tapped: ${room['title']}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Borrowscreens(
                              roomTitle: room['title'] ?? '',
                              roomSubtitle: room['subtitle'] ?? '',
                            ),
                          ),
                        );
                        print('Kartu "${room['title']}" ditekan');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFFF7643),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
              color: const Color.fromARGB(255, 255, 255, 255),
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
    );
  }
}

Widget _buildCard(
    {required String title, required String subtitle, VoidCallback? onTap}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xFFFF7643),
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
  final Function(String, String) onCreate;

  CreateRoomDialog({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
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
                  print('Make Room pressed with title: ${roomNameController.text}, location: ${locationController.text}');
                  onCreate(roomNameController.text, locationController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF7643),
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
                backgroundColor: Color(0xFFFF7643),
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
