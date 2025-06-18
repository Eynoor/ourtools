import 'package:coba1/components/login/LoginForm.dart';
import 'package:coba1/size_config.dart';
import 'package:coba1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:simple_shadow/simple_shadow.dart';

class LoginComponent extends StatefulWidget {
  @override
  _LoginComponentState createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenHeight(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                SimpleShadow(
                  opacity: 0.5,
                  color: Color(0xFFFF7643),
                  offset: Offset(5, 5),
                  sigma: 2,
                  child: Image.asset(
                    "assets/images/logo.jpeg",
                    height: 150,
                    width: 202,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login",
                          style: mTitleStyle,
                        )
                      ],
                    )),
                SizedBox(height: 20),

                //memanggil kelas Login form
                Signform()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
