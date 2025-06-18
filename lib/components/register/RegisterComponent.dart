
import 'package:coba1/components/register/RegisterForm.dart';
import 'package:coba1/size_config.dart';
import 'package:flutter/material.dart';

class Registercomponent extends StatefulWidget {
  @override
  _RegisterComponentState createState() => _RegisterComponentState();
}

class _RegisterComponentState extends State<Registercomponent> {
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

                  SizedBox(height: 20),
                 Registerform()
                ],
              ),
            )),
      ),
    );
  }
}
