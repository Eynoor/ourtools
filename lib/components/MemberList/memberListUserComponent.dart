import 'package:flutter/material.dart';

class Memberlistusercomponent extends StatefulWidget {
  @override
  _MemberlistusercomponentState createState() =>
      _MemberlistusercomponentState();
}

class _MemberlistusercomponentState extends State<Memberlistusercomponent> {
  final List<Map<String, dynamic>> admin = [
    {"name": "Zaki Maybesunun", "role": "Admin"},
  ];

  final List<Map<String, dynamic>> members = [
    {"name": "Yogi Listener", "role": "Member"},
    {"name": "Barudak Sungkem", "role": "Member"},
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
              'Baseball Prinda-',
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          // Admin Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Admin",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(),
          ...admin.map((user) => _buildMemberTile(user)).toList(),
          // Member Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Member",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(),
          ...members.map((user) => _buildMemberTile(user)).toList(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list, color: const Color.fromARGB(255, 0, 0, 0)),
              onPressed: () {
                // Navigasi atau logika untuk tombol kiri
              },
            ),
            IconButton(
              icon: Icon(Icons.group, color: Colors.black),
              onPressed: () {
                // Navigasi atau logika untuk tombol kanan
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      title: Text(user["name"]),
    );
  }
}
