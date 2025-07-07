import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';

class Memberlistadmin extends StatefulWidget {
  final String roomTitle;
  const Memberlistadmin({required this.roomTitle});
  @override
  _MemberlistadminState createState() => _MemberlistadminState();
}

class _MemberlistadminState extends State<Memberlistadmin> {
  String? adminName;
  List<String> members = [];
  final DBHelper _dbHelper = DBHelper();
  int? roomId;

  @override
  void initState() {
    super.initState();
    _loadAdminAndMembers();
  }

  Future<void> _loadAdminAndMembers() async {
    // Ambil room dari judul
    final rooms = await _dbHelper.getRoomsByTitle(widget.roomTitle);
    if (rooms.isNotEmpty) {
      roomId = rooms.first['id'];
      adminName = rooms.first['creatorUsername'] as String?;
      // Ambil member dari tabel room_members
      final memberList = await _dbHelper.getMembersByRoomId(roomId!);
      setState(() {
        members = memberList;
      });
    } else {
      setState(() {
        adminName = 'Unknown';
        members = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(adminName ?? '', style: TextStyle(color: Colors.white)),
          subtitle: Text('Admin', style: TextStyle(color: Colors.orangeAccent)),
        ),
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
        ...members.map((username) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(username, style: TextStyle(color: Colors.white)),
              subtitle:
                  Text('Member', style: TextStyle(color: Colors.blue[200])),
            )),
      ],
    );
  }
}
