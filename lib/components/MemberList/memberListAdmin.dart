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
                  icon: Icon(Icons.copy, color: Colors.blue),
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
                  icon: Icon(Icons.copy, color: Colors.blue),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditModal(context);
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.edit, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.list, color: Colors.white),
              onPressed: () {
                // Navigasi atau logika untuk tombol kiri
              },
            ),
            IconButton(
              icon: Icon(Icons.group, color: Colors.white),
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
