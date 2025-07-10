import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';

class MonitoringComponent extends StatefulWidget {
  final int roomId;
  final String roomTitle;

  MonitoringComponent({required this.roomId, required this.roomTitle});

  @override
  _MonitoringComponentState createState() => _MonitoringComponentState();
}

class _MonitoringComponentState extends State<MonitoringComponent> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _activeBorrows = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveBorrows();
  }

  Future<void> _loadActiveBorrows() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil semua barang di room ini
      final barangList = await _dbHelper.getBarangByRoom(widget.roomId);
      List<Map<String, dynamic>> activeBorrows = [];

      // Untuk setiap barang, cari peminjaman yang masih aktif
      for (final barang in barangList) {
        final peminjaman = await _dbHelper.getPeminjamanByBarang(barang['id']);
        
        // Filter hanya yang statusnya 'dipinjam'
        final activePeminjaman = peminjaman.where((p) => p['status'] == 'dipinjam').toList();
        
        for (final pinjam in activePeminjaman) {
          activeBorrows.add({
            ...pinjam,
            'nama_barang': barang['nama_barang'],
            'barang_image': barang['image'],
          });
        }
      }

      // Urutkan berdasarkan tanggal pinjam terbaru
      activeBorrows.sort((a, b) => 
        DateTime.parse(b['tanggal_pinjam']).compareTo(DateTime.parse(a['tanggal_pinjam']))
      );

      setState(() {
        _activeBorrows = activeBorrows;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading active borrows: $e');
      setState(() {
        _activeBorrows = [];
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getInitials(String username) {
    if (username.isEmpty) return 'U';
    return username.substring(0, 1).toUpperCase();
  }

  Color _getAvatarColor(String username) {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];
    return colors[username.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF012435),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFEF9823)))
          : _activeBorrows.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monitor, size: 64, color: Colors.white54),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada peminjaman aktif',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Semua barang tersedia',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadActiveBorrows,
                  color: Color(0xFFEF9823),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _activeBorrows.length,
                    itemBuilder: (context, index) {
                      final borrow = _activeBorrows[index];
                      final username = borrow['username'] as String;
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.orange.shade50, Colors.orange.shade100],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Avatar user
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: _getAvatarColor(username),
                                      child: Text(
                                        _getInitials(username),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            username,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Meminjam barang',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFEF9823),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'AKTIF',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      // Gambar barang atau icon default
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: borrow['barang_image'] != null
                                            ? Image.memory(
                                                borrow['barang_image'],
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFEF9823),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.inventory,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              borrow['nama_barang'] ?? 'Barang Tidak Diketahui',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.inventory, 
                                                    color: Colors.grey.shade600, size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Jumlah: ${borrow['jumlah']} buah',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, 
                                        color: Colors.grey.shade600, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Dipinjam ${_formatDate(borrow['tanggal_pinjam'])}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}