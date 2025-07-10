import 'package:coba1/components/cs/ContactusComponent.dart';
import 'package:coba1/components/upgrade/UpgradeProComponent.dart';
import 'package:coba1/components/notif/NotifComponent.dart';

import 'package:coba1/screens/Home/HomeScreens.dart';
import 'package:coba1/size_config.dart';
import 'package:coba1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

/// Import halaman tujuan

class Settingcomponent extends StatefulWidget {
  @override
  _SettingcomponentState createState() => _SettingcomponentState();
}

class _SettingcomponentState extends State<Settingcomponent> {
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
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
                          Navigator.pushNamed(context, Homescreens.routeName);
                        },
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengaturan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Kelola aplikasi dan akun Anda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
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
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Indicator bar
                          Container(
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
                          
                          SizedBox(height: 30),
                          
                          // Logo Section
                          Container(
                            padding: EdgeInsets.all(20),
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
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.info, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Profile tersedia di sidebar home'),
                                      ],
                                    ),
                                    backgroundColor: Color(0xFFEF9823),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                              child: Image.asset(
                                "assets/images/logo.jpeg",
                                height: 120,
                                width: 160,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 40),
                          
                          // Settings Menu
                          _buildModernButton(
                            icon: Icons.notifications_outlined,
                            title: 'Notifikasi',
                            subtitle: 'Kelola notifikasi aplikasi',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => NotifComponent()),
                              );
                            },
                          ),
                          
                          SizedBox(height: 16),
                          
                          _buildModernButton(
                            icon: Icons.headset_mic_outlined,
                            title: 'Customer Service',
                            subtitle: 'Hubungi tim support kami',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Contactuscomponent()),
                              );
                            },
                          ),
                          
                          SizedBox(height: 16),
                          
                          _buildModernButton(
                            icon: Icons.workspace_premium,
                            title: 'Upgrade Pro',
                            subtitle: 'Dapatkan fitur premium',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => UpgradeProComponent()),
                              );
                            },
                            isPremium: true,
                          ),
                          
                          SizedBox(height: 16),
                          
                          _buildModernButton(
                            icon: Icons.info_outline,
                            title: 'Informasi',
                            subtitle: 'Tentang aplikasi dan versi',
                            onPressed: () {
                              _showInfoDialog();
                            },
                          ),
                          
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFEF9823),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, Homescreens.routeName);
              },
              icon: const Icon(Icons.home),
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: Color(0xFFEF9823)),
              SizedBox(width: 8),
              Text('Informasi Aplikasi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OurTools - Inventory Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Versi: 1.0.0'),
              SizedBox(height: 4),
              Text('Build: 2024.01'),
              SizedBox(height: 16),
              Text(
                'Aplikasi manajemen inventaris yang memudahkan Anda mengelola barang dan peminjaman dengan efisien.',
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF9823),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isPremium 
              ? Border.all(color: Color(0xFFEF9823), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isPremium
                    ? LinearGradient(
                        colors: [Color(0xFFEF9823), Color(0xFFD8860B)],
                      )
                    : LinearGradient(
                        colors: [Color(0xFF012435), Color(0xFF012435).withOpacity(0.8)],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isPremium ? Color(0xFFEF9823) : Color(0xFF012435)).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            
            SizedBox(width: 20),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      if (isPremium) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFEF9823), Color(0xFFD8860B)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
