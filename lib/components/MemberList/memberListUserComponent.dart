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
    // Widget ini sekarang hanya berisi kontennya saja, tanpa Scaffold/AppBar
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        // Admin Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Admin",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Divider(color: Colors.white24),
        ...admin.map((user) => _buildMemberTile(user)).toList(),
        // Member Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Member",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Divider(color: Colors.white24),
        ...members.map((user) => _buildMemberTile(user)).toList(),
      ],
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white24,
        child: Icon(
          Icons.person,
          color: Colors.white,
        ),
      ),
      title: Text(user["name"], style: TextStyle(color: Colors.white)),
    );
  }
}
