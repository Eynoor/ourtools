import 'package:coba1/screens/Borrow/borrowScreens.dart';
import 'package:coba1/screens/Borrow/borrowUserScreens.dart';
import 'package:coba1/screens/Home/HomeScreens.dart';
import 'package:coba1/screens/dataDiri/data.dart';
import 'package:coba1/screens/login/LoginScreens.dart';
import 'package:coba1/screens/opening/opening.dart';
import 'package:coba1/screens/register/register.dart';
import 'package:coba1/screens/setting/Settingscreens.dart';
import 'package:flutter/material.dart';

final Map <String, WidgetBuilder> routes = {
  
  Openingscreen.routeName : (context) => Openingscreen(),
  Loginscreens.routeName : (context) => Loginscreens(),
  RegisterScreen.routeName : (context) => RegisterScreen(),
   Datascreens.routeName : (context) => Datascreens(),
  Homescreens.routeName : (context) => Homescreens(),
  Settingscreens.routeName : (context) => Settingscreens(),
  Borrowscreens.routeName : (context) => Borrowscreens(),
  BorrowUserscreens.routeName : (context) => BorrowUserscreens(),

};