import 'dart:typed_data';
import 'package:coba1/components/Borrow/borrowComponent.dart';
import 'package:coba1/screens/Borrow/borrowScreens.dart';
import 'package:coba1/screens/Borrow/borrowUserScreens.dart';
import 'package:coba1/screens/setting/Settingscreens.dart';
import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';
import 'package:coba1/utils/session.dart';
import 'package:coba1/screens/opening/opening.dart';
import 'package:coba1/components/Camera/Camera.dart';
import 'package:coba1/components/History/historyPeminjamanPage.dart';

class Homecomponent extends StatefulWidget {
  @override
  _HomecomponentState createState() => _HomecomponentState();
}

class _HomecomponentState extends State<Homecomponent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> rooms = [];
  final DBHelper _dbHelper = DBHelper();
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final username = Session().currentUsername;
    if (username != null) {
      final img = await _dbHelper.getUserImage(username);
      print(
          '[DEBUG] getUserImage for $username: ${img != null ? 'Ada data' : 'NULL'}');
      if (mounted) setState(() => _profileImage = img);
    }
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

  // Helper method untuk membuat menu item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white.withOpacity(0.5),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Helper method untuk dialog logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.orange.shade400),
            SizedBox(width: 8),
            Text('Konfirmasi Logout'),
          ],
        ),
        content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Session().currentUsername = null;
              Navigator.pushNamedAndRemoveUntil(
                context,
                Openingscreen.routeName,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Helper method untuk dialog hapus akun
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus Akun'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus akun ini?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                '⚠️ Semua data Anda akan hilang dan tidak bisa dikembalikan.',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final username = Session().currentUsername;
              if (username != null) {
                await _dbHelper.deleteUser(username);
                Session().currentUsername = null;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Openingscreen.routeName,
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Akun berhasil dihapus'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Hapus Akun'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFF012435),
      drawer: Drawer(
        backgroundColor: Color(0xFF012435),
        child: SafeArea(
          child: Column(
            children: [
              // Header Profile Section
              Container(
                height: 240, // Reduced height
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEF9823),
                      Color(0xFFEF9823).withOpacity(0.8),
                      Color(0xFF012435).withOpacity(0.3),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16), // Reduced padding
                  child: Column(
                    children: [
                      // Profile Picture with glow effect
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 35, // Reduced radius
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: _profileImage != null
                                ? MemoryImage(_profileImage!)
                                : null,
                            backgroundColor: Colors.grey.shade200,
                            child: _profileImage == null
                                ? Icon(Icons.person, 
                                    color: Color(0xFFEF9823), size: 32)
                                : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 12), // Reduced spacing
                      
                      // Username
                      Text(
                        Session().currentUsername?.toUpperCase() ?? "USER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Reduced font size
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 6), // Reduced spacing
                      
                      // Welcome message
                      Text(
                        "Welcome back!",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14, // Reduced font size
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 12), // Reduced spacing
                      
                      // Status badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Online",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Menu Items - Now scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      // History Menu
                      _buildMenuItem(
                        icon: Icons.history_rounded,
                        title: 'Riwayat Peminjaman',
                        iconColor: Color(0xFFEF9823),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryPeminjamanPage(),
                            ),
                          );
                        },
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Settings Menu
                      _buildMenuItem(
                        icon: Icons.settings_rounded,
                        title: 'Pengaturan',
                        iconColor: Colors.blue.shade400,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, Settingscreens.routeName);
                        },
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Divider
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 10),
                      
                      // Logout Menu
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        iconColor: Colors.orange.shade400,
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Delete Account Menu
                      _buildMenuItem(
                        icon: Icons.delete_forever_rounded,
                        title: 'Hapus Akun',
                        iconColor: Colors.red.shade400,
                        onTap: () {
                          _showDeleteAccountDialog(context);
                        },
                      ),
                      
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 72, // dinaikkan agar icon tidak terpotong
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left:
                              12.0), // sedikit lebih kecil agar lebih fleksibel
                      child: IconButton(
                        icon: Icon(Icons.menu),
                        iconSize: 32, // sedikit lebih besar
                        color: Colors.white,
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        splashRadius: 26, // biar lebih mudah di-tap
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                        icon: Icon(Icons.add),
                        iconSize: 32,
                        color: Colors.white,
                        onPressed: () => _showOptionsModal(context),
                        splashRadius: 26,
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
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                                SnackBar(
                                    content: Text('Room berhasil dihapus')),
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
