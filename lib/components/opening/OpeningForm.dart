import 'package:coba1/components/default_custom_button_color.dart';
//import 'package:coba1/components/identitas/identitasComponent.dart';
import 'package:coba1/screens/login/LoginScreens.dart';
import 'package:coba1/screens/register/register.dart';
import 'package:coba1/size_config.dart';
import 'package:coba1/utils/constants.dart';
import 'package:flutter/material.dart';

class Openingform extends StatefulWidget {
  @override
  _Openingform createState() => _Openingform();
}

class _Openingform extends State<Openingform> {
  FocusNode focusNode = new FocusNode();
  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(children: [
      Positioned(
        left: 58,
        top: 341,
        child: Text(
          'Make Your Community now!',
          style: TextStyle(
            fontSize: 24,
            color: const Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Kameron',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      SizedBox(height: getProportionateScreenHeight(30)),
      DefaultButtonCustomeColor(
        color: const Color.fromARGB(255, 215, 123, 9),
        text: "Sign In",
        press: () {
          Navigator.pushNamed(context, Loginscreens.routeName);
        },
      ),
      SizedBox(height: getProportionateScreenHeight(20)),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, Loginscreens.routeName);
        },
        child: Text("Sudah Mempunyai Akun?",
            style: TextStyle(decoration: TextDecoration.underline)),
      ),
      DefaultButtonCustomeColor(
        color: const Color.fromARGB(255, 215, 123, 9),
        text: "Sign Up",
        press: () {
          Navigator.pushNamed(context, RegisterScreen.routeName);
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => Identitascomponent()));
        },
      ),
    ]));
  }
}
