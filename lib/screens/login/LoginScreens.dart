import 'package:coba1/components/login/LoginComponent.dart';
import 'package:flutter/material.dart';
import 'package:coba1/size_config.dart';

class Loginscreens extends StatelessWidget {

  static String routeName = "/sign_in";
    @override
    Widget build(BuildContext context) {
      SizeConfig().init(context);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: LoginComponent(),
      );
    }

}