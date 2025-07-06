import 'package:coba1/components/MemberList/memberListUserComponent.dart';
import 'package:coba1/components/Barang/barangComponent.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';

class BorrowUsercomponent extends StatefulWidget {
  @override
  _BorrowUsercomponentState createState() => _BorrowUsercomponentState();
}

class _BorrowUsercomponentState extends State<BorrowUsercomponent> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> items = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // 0 untuk daftar barang, 1 untuk daftar member
  // State to hold quantity for each item, initialized to 0
  late List<int> quantities;

  @override
  void initState() {
    super.initState();
    _loadBarang();
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
    setState(() {
      _isLoading = true;
    });
    final data = await _dbHelper.getAllBarang();
    setState(() {
      items = data;
      quantities = List<int>.filled(items.length, 0);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF012435),
      appBar: AppBar(
        backgroundColor: Color(0xFFEF9823),
        title: Text(
          _selectedIndex == 0 ? 'Gg Merah Putih' : 'Daftar Member',
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
          Memberlistusercomponent(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Color(0xFFEF9823),
              onPressed: () async {
                // Import Barangcomponent dengan path yang benar
                final newItem = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Barangcomponent()),
                );
                if (newItem == true) {
                  _loadBarang(); // Muat ulang data jika ada barang baru
                }
              },
              child: Icon(Icons.add, color: Colors.white),
            )
          : null, // Sembunyikan FAB jika bukan di halaman barang
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

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
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
                  child: Icon(Icons.sports_soccer,
                      color: const Color.fromARGB(255, 0, 0, 0), size: 30),
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
        trailing: Icon(Icons.handyman, color: Colors.grey),
        onTap: () {
          print("Tapped on $title");
        },
      ),
    );
  }
}
