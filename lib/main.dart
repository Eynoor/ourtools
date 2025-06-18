import 'package:coba1/routes.dart';
import 'package:coba1/screens/opening/opening.dart';
import 'package:coba1/theme.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "OURTOOLS",
      theme: theme(),
      initialRoute: Openingscreen.routeName,
      routes: routes));
}
