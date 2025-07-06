
import 'package:coba1/components/dataDiri/dataComponent.dart';
import 'package:flutter/material.dart';
import 'package:coba1/size_config.dart';

class Datascreens extends StatelessWidget {

  static String routeName = "/data";
    @override
    Widget build(BuildContext context) {
      SizeConfig().init(context);

      return Scaffold(
        backgroundColor: Color(0xFF012435),
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        // body: LoginComponent(),
        body: DataComponent(),
      );
    }

}