
import 'package:coba1/components/opening/OpeningComponent.dart';
import 'package:flutter/material.dart';
import 'package:coba1/size_config.dart';

class Openingscreen extends StatelessWidget {

  static String routeName = "/opening";
    @override
    Widget build(BuildContext context) {
      SizeConfig().init(context);

      return Scaffold(
        backgroundColor: Color(0xFF012435),
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        // body: LoginComponent(),
          body: Openingcomponent(),
      );
    }

}