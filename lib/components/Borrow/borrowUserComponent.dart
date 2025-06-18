import 'package:coba1/components/MemberList/memberListUserComponent.dart';
import 'package:flutter/material.dart';

class BorrowUsercomponent extends StatefulWidget {
  @override
  _BorrowUsercomponentState createState() => _BorrowUsercomponentState();
}

class _BorrowUsercomponentState extends State<BorrowUsercomponent> {
  final List<Map<String, String>> items = [
    {"title": "Bola"},
    {"title": "Mark"},
    {"title": "Baju team"},
    {"title": "Sepatu"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 8),
            Text(
              'Gg Merah Putih',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildItemCard(items[index]['title']!);
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blue,
      //   onPressed: () {
      //     // Tambahkan logika untuk aksi tombol plus
      //     print("Tambah item baru");
      //   },
      //   child: Icon(Icons.add, color: Colors.white),
      // ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list, color: Colors.black),
              onPressed: () {
                
                // Logika untuk navigasi ke halaman lain
              },
            ),
            IconButton(
              icon: Icon(Icons.group, color: Colors.white),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Memberlistusercomponent()));
                // Logika untuk navigasi ke halaman lain
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(String title) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.sports_soccer, color: Colors.white, size: 30),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.add_box_outlined, size: 18),
            SizedBox(width: 4),
            Icon(Icons.check_box_outline_blank, size: 18),
            SizedBox(width: 4),
            Icon(Icons.indeterminate_check_box_outlined, size: 18),
            SizedBox(width: 4),
            Icon(Icons.date_range_outlined, size: 18)
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
