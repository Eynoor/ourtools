import 'package:flutter/material.dart';

class Memberlistadmin extends StatefulWidget {
  @override
  _MemberlistadminState createState() => _MemberlistadminState();
}

class _MemberlistadminState extends State<Memberlistadmin> {
  final List<Map<String, dynamic>> admin = [
    {"name": "Yogi Listener", "role": "Admin"},
  ];

  final List<Map<String, dynamic>> members = [
    {"name": "Totok S.Pd", "role": "Member", "crown": true, "kick": true},
    {"name": "Human Sungkem", "role": "Member", "crown": true, "kick": true},
  ];

  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Text(
                  "Code:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                title: Text(
                  "GKH2O3",
                  style: TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.copy, color: Color(0xFF012435)),
                  onPressed: () {
                    // Tambahkan logika untuk menyalin kode
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Code copied!")),
                    );
                  },
                ),
              ),
              ListTile(
                leading: Text(
                  "Link:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                title: Text(
                  "938rin...",
                  style: TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.copy, color: Color(0xFF012435)),
                  onPressed: () {
                    // Tambahkan logika untuk menyalin link
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Link copied!")),
                    );
                  },
                ),
              ),
              SwitchListTile(
                title: Text("Enable Code Sharing"),
                value: true,
                onChanged: (bool value) {
                  // Tambahkan logika untuk mengaktifkan/nonaktifkan code sharing
                  
                },
              ),
              SwitchListTile(
                title: Text("Enable Link Sharing"),
                value: true,
                onChanged: (bool value) {
                  // Tambahkan logika untuk mengaktifkan/nonaktifkan link sharing
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
              color: Colors.white, // Ganti warna teks agar terlihat
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
              color: Colors.white, // Ganti warna teks agar terlihat
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user["crown"] == true)
            Icon(Icons.emoji_events, color: Colors.orange),
          if (user["kick"] == true)
            Icon(Icons.remove_circle_outline, color: Colors.red),
        ],
      ),
    );
  }
}
