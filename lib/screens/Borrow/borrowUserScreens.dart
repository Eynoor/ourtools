
import 'package:coba1/components/Borrow/borrowUserComponent.dart';
import 'package:coba1/size_config.dart';
import 'package:flutter/material.dart';

class BorrowUserscreens extends StatelessWidget {
  static String routeName = '/borrowuser';
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        // body: ,
        //body: Borrowcomponent(),
        //body: BorrowUsercomponent(),
       body: BorrowUsercomponent(),
        
        );
  }
}
