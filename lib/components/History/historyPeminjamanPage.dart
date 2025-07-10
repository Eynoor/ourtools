import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';
import 'package:coba1/utils/session.dart';

class HistoryPeminjamanPage extends StatefulWidget {
  @override
  _HistoryPeminjamanPageState createState() => _HistoryPeminjamanPageState();
}

class _HistoryPeminjamanPageState extends State<HistoryPeminjamanPage>
    with TickerProviderStateMixin {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  List<String> _rooms = [];
  String _selectedRoom = 'Semua Room';
  String _selectedStatus = 'Semua Status';
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final username = Session().currentUsername;
    if (username == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final data = await _dbHelper.getPeminjamanByUser(username);
    
    // Extract unique rooms
    final roomSet = <String>{};
    for (final item in data) {
      if (item['room_title'] != null) {
        roomSet.add(item['room_title']);
      }
    }
    
    setState(() {
      _allHistory = data;
      _filteredHistory = data;
      _rooms = ['Semua Room', ...roomSet.toList()];
      _isLoading = false;
    });
    
    // Apply current filters after loading data
    _filterHistory();
  }

  void _filterHistory() {
    setState(() {
      _filteredHistory = _allHistory.where((item) {
        bool roomMatch = _selectedRoom == 'Semua Room' || 
                        item['room_title'] == _selectedRoom;
        bool statusMatch = _selectedStatus == 'Semua Status' || 
                          item['status'] == _selectedStatus;
        return roomMatch && statusMatch;
      }).toList();
    });
  }

  List<Map<String, dynamic>> get _activeHistory {
    return _filteredHistory.where((item) => item['status'] == 'dipinjam').toList();
  }

  List<Map<String, dynamic>> get _completedHistory {
    return _filteredHistory.where((item) => item['status'] == 'dikembalikan').toList();
  }

  Future<void> _kembalikanBarang(Map<String, dynamic> item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Pengembalian'),
          content: Text(
              'Apakah Anda yakin ingin mengembalikan "${item['nama_barang']}" sebanyak ${item['jumlah']} buah?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Ya, Kembalikan', 
                  style: TextStyle(color: Color(0xFFEF9823))),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final now = DateTime.now().toIso8601String();
        
        // Update status peminjaman menjadi dikembalikan
        await _dbHelper.updatePeminjamanKembali(item['id'], now);
        
        // Kembalikan stok barang
        final barang = await _dbHelper.getBarangById(item['barang_id']);
        
        if (barang != null) {
          final currentStock = barang['stock'] as int;
          final returnedQuantity = item['jumlah'] as int;
          final newStock = currentStock + returnedQuantity;
          await _dbHelper.updateBarangStock(item['barang_id'], newStock);
        }

        // Refresh data
        _loadHistory();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barang berhasil dikembalikan'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error mengembalikan barang: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengembalikan barang: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Color(0xFFEF9823)),
              SizedBox(width: 8),
              Text(
                'Filter Riwayat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRoom,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Color(0xFFEF9823)),
                      items: _rooms.map((String room) {
                        return DropdownMenuItem<String>(
                          value: room,
                          child: Text(
                            room,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRoom = newValue!;
                          _filterHistory();
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Color(0xFFEF9823)),
                      items: ['Semua Status', 'dipinjam', 'dikembalikan']
                          .map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status == 'dipinjam' 
                                ? 'Sedang Dipinjam'
                                : status == 'dikembalikan'
                                    ? 'Sudah Dikembalikan'
                                    : status,
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue!;
                          _filterHistory();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final isActive = item['status'] == 'dipinjam';
    final roomTitle = item['room_title'] ?? 'Room Tidak Diketahui';
    
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
            colors: isActive 
                ? [Colors.orange.shade50, Colors.orange.shade100]
                : [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Color(0xFFEF9823) : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'DIPINJAM' : 'DIKEMBALIKAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      roomTitle,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                item['nama_barang'] ?? 'Barang Tidak Diketahui',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.inventory, color: Colors.grey.shade600, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Jumlah: ${item['jumlah']} buah',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Dipinjam: ${_formatDate(item['tanggal_pinjam'])}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (item['tanggal_kembali'] != null) ...[
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.assignment_return, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Dikembalikan: ${_formatDate(item['tanggal_kembali'])}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              if (isActive) ...[
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _kembalikanBarang(item),
                    icon: Icon(Icons.assignment_return, color: Colors.white),
                    label: Text(
                      'Kembalikan Barang',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEF9823),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'Tidak ada riwayat',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(history[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF012435),
      appBar: AppBar(
        title: Text('Riwayat Peminjaman', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFEF9823),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: _isLoading
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: Icon(Icons.access_time),
                    text: 'Aktif (${_activeHistory.length})',
                  ),
                  Tab(
                    icon: Icon(Icons.check_circle),
                    text: 'Selesai (${_completedHistory.length})',
                  ),
                ],
              ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFEF9823)))
          : _allHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.white54),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat peminjaman',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildFilterSection(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildHistoryList(_activeHistory),
                          _buildHistoryList(_completedHistory),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
