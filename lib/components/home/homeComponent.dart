import 'package:coba1/components/Borrow/borrowComponent.dart';
import 'package:coba1/screens/Borrow/borrowScreens.dart';
import 'package:coba1/screens/Borrow/borrowUserScreens.dart';
import 'package:coba1/screens/setting/Settingscreens.dart';
import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';
import 'package:coba1/utils/session.dart';
import 'package:coba1/screens/opening/opening.dart';

class Homecomponent extends StatefulWidget {
  @override
  _HomecomponentState createState() => _HomecomponentState();
}

class _HomecomponentState extends State<Homecomponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> rooms = [];
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final session = Session();
    final currentUser = session.currentUsername ?? 'unknown';
    final List<Map<String, dynamic>> roomsFromDB =
        await _dbHelper.getAllRoomsForUser(currentUser);
    if (roomsFromDB.isNotEmpty) {
      setState(() {
        rooms = roomsFromDB
            .map((e) => {
                  'title': e['title'] as String,
                  'subtitle': e['subtitle'] as String,
                  'creatorUsername': e['creatorUsername'] as String? ?? '',
                })
            .toList();
      });
    } else {
      setState(() {
        rooms = [];
      });
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
                        return EnterRoomDialog(
                          onEnter: (String roomCode) async {
                            Navigator.pop(context);
                            final dbHelper = DBHelper();
                            final roomsFromDB =
                                await dbHelper.getRoomByTitle(roomCode);
                            if (roomsFromDB.isNotEmpty) {
                              final roomData = roomsFromDB.first;
                              final session = Session();
                              final currentUser =
                                  session.currentUsername ?? 'unknown';
                              final alreadyMember =
                                  await dbHelper.isUserMemberOfRoom(
                                      roomData['id'], currentUser);
                              if (!alreadyMember) {
                                await dbHelper.addMemberToRoom(
                                    roomData['id'], currentUser);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Borrowscreens(
                                      roomTitle: roomData['title'] ?? '',
                                      roomSubtitle: roomData['subtitle'] ?? '',
                                    ),
                                  ),
                                );
                              } else {
                                // Sudah member, tampilkan pesan dan tetap navigasi ke room
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Kamu sudah menjadi member room ini.')),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Borrowscreens(
                                      roomTitle: roomData['title'] ?? '',
                                      roomSubtitle: roomData['subtitle'] ?? '',
                                    ),
                                  ),
                                );
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Room tidak ditemukan'),
                                  content: Text(
                                      'Room dengan nama "${roomCode}" tidak ada.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.create),
                  title: Text('Create Room'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CreateRoomDialog(
                          onCreate: (String title, String subtitle) async {
                            final session = Session(); // ✅ PERBAIKAN
                            final currentUser =
                                session.currentUsername ?? 'unknown';

                            await _dbHelper.insertRoom({
                              'title': title,
                              'subtitle': subtitle,
                              'creatorUsername': currentUser,
                            });
                            await _loadRooms();
                            Navigator.pop(context);
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
      key: _scaffoldKey,
      backgroundColor: Color(0xFF012435),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEF9823), Color(0xFFFF7643)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              NetworkImage("https://via.placeholder.com/150"),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Session().currentUsername?.toUpperCase() ??
                                  "USER",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Welcome back!",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Online",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Settingscreens.routeName);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.white),
              title: Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Add about page navigation
              },
            ),
            Divider(color: Colors.white30),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[300]),
              title: Text('Logout', style: TextStyle(color: Colors.red[300])),
              onTap: () {
                // Clear session and navigate to opening
                Session().currentUsername = null;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Openingscreen.routeName,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      iconSize: 30,
                      color: Colors.white,
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      iconSize: 30,
                      color: Colors.white,
                      onPressed: () => _showOptionsModal(context),
                    ),
                  ),
                ],
              ),
            ),
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
                      creatorUsername: room['creatorUsername'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Borrowscreens(
                              roomTitle: room['title'] ?? '',
                              roomSubtitle: room['subtitle'] ?? '',
                            ),
                          ),
                        );
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Hapus Room'),
                            content: Text(
                                'Yakin ingin menghapus room ini? Semua barang di dalamnya juga akan terhapus.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Hapus',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // Ambil id room dari DB
                          final session = Session();
                          final currentUser =
                              session.currentUsername ?? 'unknown';
                          final dbHelper = DBHelper();
                          final roomsFromDB =
                              await dbHelper.getRooms(currentUser);
                          final roomData = roomsFromDB.firstWhere(
                            (r) =>
                                r['title'] == room['title'] &&
                                r['subtitle'] == room['subtitle'],
                            orElse: () => {},
                          );
                          if (roomData.isNotEmpty) {
                            await dbHelper.deleteRoom(roomData['id']);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Room berhasil dihapus')),
                            );
                            // ignore: use_build_context_synchronously
                            await _loadRooms(); // reload rooms agar UI terupdate
                          }
                        }
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
        color: Color(0xFFEF9823),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
              color: const Color.fromARGB(255, 3, 3, 3),
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
    {required String title,
    required String subtitle,
    String? creatorUsername,
    VoidCallback? onTap,
    VoidCallback? onDelete}) {
  final session = Session();
  final currentUser = session.currentUsername ?? 'unknown';
  final isAdminRoom = creatorUsername == currentUser;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEF9823),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
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
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null && isAdminRoom)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFF3B30), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white, size: 28),
                onPressed: onDelete,
                tooltip: 'Hapus Room',
              ),
            ),
        ],
      ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Make your own room',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: roomNameController,
                decoration: InputDecoration(
                  labelText: 'Room name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onCreate(roomNameController.text, locationController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEF9823),
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
  final Function(String) onEnter;

  EnterRoomDialog({required this.onEnter});

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: roomCodeController,
              decoration: InputDecoration(
                labelText: 'Enter code room',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onEnter(roomCodeController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF9823),
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
