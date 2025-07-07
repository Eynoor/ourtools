import 'package:coba1/components/Barang/barangComponent.dart';
import 'package:coba1/components/MemberList/memberListAdmin.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';
import 'package:coba1/utils/session.dart';

class Borrowcomponent extends StatefulWidget {
  final String roomTitle;
  final String roomSubtitle;

  Borrowcomponent({required this.roomTitle, required this.roomSubtitle});

  @override
  _BorrowcomponentState createState() => _BorrowcomponentState();
}

class _BorrowcomponentState extends State<Borrowcomponent> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> items = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // 0 untuk daftar barang, 1 untuk daftar member
  // State to hold quantity for each item, initialized to 0
  late List<int> quantities;
  int? roomId;
  String? adminUsername;

  @override
  void initState() {
    super.initState();
    _initRoom();
  }

  Future<void> _initRoom() async {
    // Ambil roomId dari database berdasarkan judul room
    final rooms = await _dbHelper.getRoomsByTitle(widget.roomTitle);
    if (rooms.isNotEmpty) {
      setState(() {
        roomId = rooms.first['id'];
        adminUsername = rooms.first['creatorUsername'];
      });
      _loadBarang();
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room tidak ditemukan')),
      );
    }
  }

  bool get isAdmin {
    final session = Session();
    return session.currentUsername == adminUsername;
  }

  // Fungsi untuk mengubah state saat item di BottomAppBar ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Widget untuk menampilkan daftar barang (dipisahkan agar rapi)
  Widget _buildItemListView() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : items.isEmpty
            ? Center(
                child: Text('Belum ada barang.',
                    style: TextStyle(color: Colors.white)))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildItemCard(items[index], index);
                });
  }

  Future<void> _loadBarang() async {
    if (roomId == null) return;
    setState(() {
      _isLoading = true;
    });
    final data = await _dbHelper.getBarangByRoom(roomId!);
    setState(() {
      items = data;
      quantities = List<int>.filled(items.length, 0);
      _isLoading = false;
    });
  }

  void _initializeQuantities() {
    quantities = List<int>.filled(items.length, 0);
  }

  Future<void> _deleteBarang(int id) async {
    // Tampilkan dialog konfirmasi sebelum menghapus
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus barang ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // Jika pengguna mengonfirmasi, hapus barang dari database
    if (confirmed == true) {
      await _dbHelper.deleteBarang(id);
      _loadBarang(); // Muat ulang daftar barang untuk memperbarui UI
    }
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    final int id = item['id'] as int;
    final String title = item['nama_barang'] as String;
    final int stock = item['stock'] as int? ?? 0;
    final Uint8List? imageBytes = item['image'] as Uint8List?;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: imageBytes != null && imageBytes.isNotEmpty
              ? Image.memory(
                  imageBytes,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFEF9823),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(Icons.sports_soccer, color: Colors.white, size: 30),
                ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Stok: $stock',
                style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
        subtitle: Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                setState(() {
                  if (quantities[index] > 0) {
                    quantities[index]--;
                  }
                });
              },
            ),
            Text(
              quantities[index].toString(),
              style: TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () {
                setState(() {
                  if (quantities[index] < stock) {
                    quantities[index]++;
                  }
                });
              },
            ),
          ],
        ),
        trailing: isAdmin
            ? IconButton(
                icon: Icon(Icons.delete, color: Colors.red[400]),
                onPressed: () {
                  _deleteBarang(id);
                },
              )
            : null,
        onTap: () {
          print("Tapped on $title");
        },
      ),
    );
  }

  void _openAddBarang() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Barangcomponent(roomId: roomId!),
      ),
    );
    if (result == true) {
      _loadBarang();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF012435),
      appBar: AppBar(
        backgroundColor: Color(0xFFEF9823),
        title: Text(
          _selectedIndex == 0 ? widget.roomTitle : 'Daftar Member',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          // Halaman 0: Daftar Barang
          _buildItemListView(),
          // Halaman 1: Daftar Member
          Memberlistadmin(roomTitle: widget.roomTitle),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 && isAdmin
          ? FloatingActionButton(
              backgroundColor: Color(0xFFEF9823),
              onPressed: () async {
                _openAddBarang();
              },
              child: Icon(Icons.add, color: Colors.white),
            )
          : null, // Sembunyikan FAB jika bukan di halaman barang atau bukan admin
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFEF9823),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list,
                  color: _selectedIndex == 0 ? Colors.black : Colors.white),
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            IconButton(
              icon: Icon(Icons.group,
                  color: _selectedIndex == 1 ? Colors.black : Colors.white),
              onPressed: () {
                _onItemTapped(1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
