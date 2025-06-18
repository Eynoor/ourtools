import 'package:coba1/components/cs/ContactusComponent.dart';
import 'package:coba1/components/donate/DonateComponent.dart';
import 'package:coba1/components/notif/NotifComponent.dart';
import 'package:coba1/components/setting/profil_page.dart';
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
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenHeight(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: SizeConfig.screenHeight * 0.04),
                  SimpleShadow(
                    opacity: 0.5,
                    color: kSecondaryColor,
                    offset: Offset(5, 5),
                    sigma: 2,
                    // child: Image.asset(
                    //   "assets/images/logo.jpeg",
                    //   height: 150,
                    //   width: 202,
                    // ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                    child: Image.asset(
                      "assets/images/logo.jpeg",
                      height: 150,
                      width: 202,
                    ),
                    ),
                  ),
                  SizedBox(height: 40),

                  /// Tombol Navigasi
                  _customButton(Icons.notifications, 'Notif', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotifComponent()),
                    );
                  }),
                  SizedBox(height: 16),
                  _customButton(Icons.headset_mic, 'CS', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Contactuscomponent()),
                    );
                  }),
                  SizedBox(height: 16),
                  _customButton(Icons.volunteer_activism, 'Donate', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Donatecomponent()),
                    );
                  }),
                  SizedBox(height: 16),
                  _customButton(Icons.info, 'Info', () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => InfoPage()),
                    // );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
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
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Fungsi untuk Membuat Tombol Kustom dengan Navigasi
  Widget _customButton(IconData icon, String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
