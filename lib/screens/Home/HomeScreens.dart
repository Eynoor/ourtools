import 'package:coba1/components/home/homeComponent.dart';
import 'package:coba1/size_config.dart';
import 'package:flutter/material.dart';

class Homescreens extends StatelessWidget {
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Homecomponent(),
    );
  }
}