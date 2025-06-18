import 'package:coba1/components/dataDiri/dataForm.dart';
import 'package:coba1/size_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DataComponent extends StatefulWidget {
  @override
  _DataComponentState createState() => _DataComponentState();
}

class _DataComponentState extends State<DataComponent> {
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
              Dataform()
              ],
            ),
          ),
        ),
      ),
    );
  }
}