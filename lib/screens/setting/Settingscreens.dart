
import 'package:coba1/components/setting/SettingComponent.dart';
import 'package:coba1/size_config.dart';
import 'package:flutter/material.dart';

class Settingscreens extends StatelessWidget {
  static String routeName = "/setting";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      
      ),
      // body: Container(), // Tambahkan body untuk Scaffold
      // body: Homecomponent(),
      body: Settingcomponent(),
    );
  }
}