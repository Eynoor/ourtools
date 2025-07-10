import 'package:coba1/components/Barang/barangComponent.dart';
import 'package:coba1/components/MemberList/memberListAdmin.dart';
import 'package:coba1/components/Monitoring/monitoringComponent.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _selectedIndex = 0; // 0 untuk daftar barang, 1 untuk daftar member, 2 untuk monitoring
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
    try {
      final data = await _dbHelper.getBarangByRoom(roomId!);
      setState(() {
        items = data;
        // Pastikan quantities selalu memiliki panjang yang sama dengan items
        quantities = List<int>.filled(items.length >= 0 ? items.length : 0, 0);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading barang: $e');
      setState(() {
        items = [];
        quantities = [];
        _isLoading = false;
      });
    }
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
                  if (index < quantities.length && quantities[index] > 0) {
                    quantities[index]--;
                  }
                });
              },
            ),
            Text(
              index < quantities.length ? quantities[index].toString() : '0',
              style: TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: () {
                setState(() {
                  if (index < quantities.length && quantities[index] < stock) {
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

  Future<void> _onCheckout() async {
    final selected = <Map<String, dynamic>>[];
    for (int i = 0; i < items.length && i < quantities.length; i++) {
      if (quantities[i] > 0) {
        selected.add({
          ...items[i],
          'jumlah': quantities[i],
        });
      }
    }

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih barang yang akan dipinjam.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF9823), Color(0xFFD8860B)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart_checkout, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Konfirmasi Peminjaman',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Anda akan meminjam ${selected.length} jenis barang dengan total ${selected.fold(0, (sum, item) => sum + (item['jumlah'] as int))} item.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Items List
                      Text(
                        'Detail Peminjaman:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Scrollable Items List
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: selected.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[300],
                          ),
                          itemBuilder: (context, index) {
                            final item = selected[index];
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEF9823),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item['nama_barang'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEF9823),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${item['jumlah']} pcs',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      if (selected.length > 3) ...[
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Scroll untuk melihat semua barang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Actions
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFEF9823),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Ya, Pinjam',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final session = Session();
      final username = session.currentUsername ?? 'unknown';
      final now = DateTime.now().toIso8601String();

      for (final item in selected) {
        final newStock = (item['stock'] as int) - (item['jumlah'] as int);
        await _dbHelper.updateBarangStock(item['id'], newStock);
        await _dbHelper.insertPeminjaman(
          barangId: item['id'],
          username: username,
          jumlah: item['jumlah'],
          tanggalPinjam: now,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barang berhasil dipinjam.')),
      );

      // Muat ulang data untuk refresh stok dan reset kuantitas
      _loadBarang();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF012435),
              Color(0xFF012435).withOpacity(0.95),
              Color(0xFF012435).withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildModernHeader(),
              
              // Content Area
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Indicator bar
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFEF9823),
                              Color(0xFFD8860B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Tab Navigation
                      _buildTabNavigation(),
                      
                      // Content
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: <Widget>[
                            // Halaman 0: Daftar Barang
                            _buildModernItemListView(),
                            // Halaman 1: Daftar Member
                            Memberlistadmin(roomTitle: widget.roomTitle),
                            // Halaman 2: Monitoring
                            roomId != null 
                                ? MonitoringComponent(roomId: roomId!, roomTitle: widget.roomTitle)
                                : Center(child: CircularProgressIndicator()),
                          ],
                        ),
                      ),
                      
                      // Checkout Button
                      if (_selectedIndex == 0 &&
                          quantities.isNotEmpty && 
                          quantities.any((quantity) => quantity > 0))
                        _buildCheckoutButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0 && isAdmin
          ? _buildModernFAB()
          : null,
    );
  }

  // Modern Header Widget
  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Top Row with Back Button and Room Info
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.roomTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          widget.roomSubtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Role Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAdmin 
                      ? Color(0xFFEF9823).withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAdmin 
                        ? Color(0xFFEF9823)
                        : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.group,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      isAdmin ? 'Admin' : 'Member',
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
          
          SizedBox(height: 20),
          
          // Stats Row
          if (_selectedIndex == 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Total Barang',
                    value: '${items.length}',
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Dipilih',
                    value: '${quantities.where((q) => q > 0).length}',
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildStatItem(
                    icon: Icons.numbers_outlined,
                    label: 'Total Qty',
                    value: '${quantities.fold(0, (sum, q) => sum + q)}',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(0xFFEF9823),
          size: 20,
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Tab Navigation Widget
  Widget _buildTabNavigation() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabItem(
            index: 0,
            icon: Icons.inventory_2_outlined,
            label: 'Barang',
          ),
          _buildTabItem(
            index: 1,
            icon: Icons.group_outlined,
            label: 'Member',
          ),
          _buildTabItem(
            index: 2,
            icon: Icons.monitor_outlined,
            label: 'Monitor',
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _onItemTapped(index);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [Color(0xFFEF9823), Color(0xFFD8860B)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color(0xFFEF9823).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Item List View
  Widget _buildModernItemListView() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF9823)),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat barang...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: _buildModernItemCard(items[index], index),
        );
      },
    );
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Color(0xFFEF9823).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: Color(0xFFEF9823),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Belum Ada Barang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 12),
            Text(
              isAdmin
                  ? 'Mulai dengan menambahkan barang pertama\nke dalam room ini'
                  : 'Admin belum menambahkan barang\nke dalam room ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            if (isAdmin) ...[
              SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _openAddBarang();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEF9823), Color(0xFFD8860B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFEF9823).withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Tambah Barang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Modern Item Card Widget
  Widget _buildModernItemCard(Map<String, dynamic> item, int index) {
    final int id = item['id'] as int;
    final String title = item['nama_barang'] as String;
    final int stock = item['stock'] as int? ?? 0;
    final Uint8List? imageBytes = item['image'] as Uint8List?;
    final int currentQuantity = index < quantities.length ? quantities[index] : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Image Container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageBytes != null && imageBytes.isNotEmpty
                        ? Image.memory(
                            imageBytes,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFEF9823), Color(0xFFD8860B)],
                              ),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Item Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: stock > 0 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: stock > 0 
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              stock > 0 ? Icons.check_circle : Icons.warning,
                              color: stock > 0 ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Stok: $stock',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: stock > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Delete Button for Admin
                if (isAdmin)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showDeleteDialog(id, title);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Quantity Controls
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jumlah Pinjam:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: currentQuantity > 0
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  if (index < quantities.length) {
                                    quantities[index]--;
                                  }
                                });
                              }
                            : null,
                        isDecrease: true,
                      ),
                      
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFEF9823)),
                        ),
                        child: Text(
                          currentQuantity.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEF9823),
                          ),
                        ),
                      ),
                      
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: currentQuantity < stock
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  if (index < quantities.length) {
                                    quantities[index]++;
                                  }
                                });
                              }
                            : null,
                        isDecrease: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDecrease,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? LinearGradient(
                  colors: isDecrease
                      ? [Colors.red[400]!, Colors.red[600]!]
                      : [Colors.green[400]!, Colors.green[600]!],
                )
              : null,
          color: onPressed == null ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: (isDecrease ? Colors.red : Colors.green).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.grey[500],
          size: 20,
        ),
      ),
    );
  }

  // Modern FAB
  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEF9823), Color(0xFFD8860B)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFEF9823).withOpacity(0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          HapticFeedback.mediumImpact();
          _openAddBarang();
        },
        child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  // Checkout Button
  Widget _buildCheckoutButton() {
    final selectedCount = quantities.where((q) => q > 0).length;
    final totalQuantity = quantities.fold(0, (sum, q) => sum + q);
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Dipilih:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '$selectedCount barang ($totalQuantity qty)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF9823),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEF9823), Color(0xFFD8860B)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFEF9823).withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _onCheckout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Pinjam Barang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Delete Dialog
  void _showDeleteDialog(int id, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
              SizedBox(width: 8),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menghapus barang ini?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.orange.shade700, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        itemName,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
              onPressed: () {
                Navigator.pop(context);
                _deleteBarang(id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
