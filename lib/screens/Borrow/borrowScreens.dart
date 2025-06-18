import 'package:coba1/components/Borrow/borrowComponent.dart';
import 'package:coba1/size_config.dart';
import 'package:flutter/material.dart';

class Borrowscreens extends StatelessWidget {
  static String routeName = '/borrow';
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        // body: ,
        body: Borrowcomponent(),
        
        );
  }
}
