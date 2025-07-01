import 'package:coba1/components/Borrow/borrowComponent.dart';
import 'package:coba1/size_config.dart';
import 'package:flutter/material.dart';

class Borrowscreens extends StatelessWidget {
  static String routeName = '/borrow';
  final String roomTitle;
  final String roomSubtitle;

  Borrowscreens({required this.roomTitle, required this.roomSubtitle});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        // body: ,
        body: Borrowcomponent(
          roomTitle: roomTitle,
          roomSubtitle: roomSubtitle,
        ),
        
        );
  }
}
