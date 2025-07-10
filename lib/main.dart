import 'package:flutter/material.dart';
import 'package:coba1/routes.dart';
import 'package:coba1/screens/opening/opening.dart';
import 'package:coba1/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OURTOOLS',
      theme: theme(),
      initialRoute: Openingscreen.routeName,
      routes: routes,
    );
  }
}
