import 'package:flutter/material.dart';
import 'package:coba1/utils/db_helper.dart';
import 'package:coba1/utils/session.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAdminAndMembers();
  }

  Future<void> _loadAdminAndMembers() async {
    setState(() {
      _isLoading = true;
    });
    
    // Ambil room dari judul
    final rooms = await _dbHelper.getRoomsByTitle(widget.roomTitle);
    if (rooms.isNotEmpty) {
      roomId = rooms.first['id'];
      adminName = rooms.first['creatorUsername'] as String?;
      // Ambil member dari tabel room_members
      final memberList = await _dbHelper.getMembersByRoomId(roomId!);
      setState(() {
        members = memberList;
        _isLoading = false;
      });
    } else {
      setState(() {
        adminName = 'Unknown';
        members = [];
        _isLoading = false;
      });
    }
  }

  bool get isCurrentUserAdmin {
    final session = Session();
    return session.currentUsername == adminName;
  }

  Future<void> _kickMember(String memberUsername) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, 
                   color: Colors.orange, size: 24), // Reduced size
              SizedBox(width: 8),
              Expanded( // Added Expanded to prevent overflow
                child: Text(
                  'Konfirmasi Kick Member',
                  style: TextStyle(fontSize: 18), // Reduced font size
                ),
              ),
            ],
          ),
          content: SingleChildScrollView( // Added ScrollView
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apakah Anda yakin ingin mengeluarkan member ini dari room?',
                    style: TextStyle(fontSize: 15), // Reduced font size
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.red.shade600, size: 20),
                        SizedBox(width: 8),
                        Expanded( // Added Expanded to prevent overflow
                          child: Text(
                            memberUsername,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis, // Handle long usernames
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Member yang dikeluarkan tidak akan bisa mengakses room ini lagi.',
                    style: TextStyle(
                      fontSize: 13, // Reduced font size
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Kick Member',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16), // Better padding
        );
      },
    );

    if (confirmed == true && roomId != null) {
      try {
        await _dbHelper.removeMemberFromRoom(roomId!, memberUsername);
        
        // Refresh member list
        _loadAdminAndMembers();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('$memberUsername berhasil dikeluarkan dari room'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Gagal mengeluarkan member: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
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

  String _getInitials(String username) {
    if (username.isEmpty) return 'U';
    return username.substring(0, 1).toUpperCase();
  }

  Widget _buildMemberCard(String username, {bool isAdmin = false}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isAdmin 
              ? Color(0xFFEF9823) 
              : _getAvatarColor(username),
          child: Text(
            _getInitials(username),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          username,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isAdmin 
                ? Color(0xFFEF9823)
                : Colors.blue.shade600,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: (isAdmin ? Color(0xFFEF9823) : Colors.blue.shade600).withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            isAdmin ? 'Admin' : 'Member',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: !isAdmin && isCurrentUserAdmin
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.person_remove,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  onPressed: () => _kickMember(username),
                  tooltip: 'Kick Member',
                ),
              )
            : isAdmin
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFEF9823).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFFEF9823),
                      size: 20,
                    ),
                  )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFFEF9823)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        // Header dengan statistik
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEF9823), Color(0xFFEF9823).withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.group, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Anggota',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${members.length + 1} orang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Spacer(),
              if (isCurrentUserAdmin)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Admin Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Admin Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFFEF9823), size: 20),
              SizedBox(width: 8),
              Text(
                "Admin",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        if (adminName != null)
          _buildMemberCard(adminName!, isAdmin: true),

        // Member Section
        if (members.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.blue.shade300, size: 20),
                SizedBox(width: 8),
                Text(
                  "Member (${members.length})",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isCurrentUserAdmin) ...[
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: Colors.red.shade400, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Tap untuk kick',
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          ...members.map((username) => _buildMemberCard(username)),
        ],

        // Empty state untuk member
        if (members.isEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: Colors.white54,
                ),
                SizedBox(height: 12),
                Text(
                  'Belum ada member',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Invite orang lain untuk bergabung',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
