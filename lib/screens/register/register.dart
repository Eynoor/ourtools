
import 'package:coba1/components/register/RegisterComponent.dart';
import 'package:flutter/material.dart';
import 'package:coba1/size_config.dart';

class RegisterScreen extends StatelessWidget {

  static String routeName = "/register";
    @override
    Widget build(BuildContext context) {
      SizeConfig().init(context);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Registercomponent(),
        // body: LoginComponent(),
        
      );
    }

}