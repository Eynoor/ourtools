import 'package:flutter/material.dart';
import 'package:coba1/components/custom_surfix_icon.dart';
import 'package:coba1/components/default_custom_button_color.dart';
import 'package:coba1/screens/Home/HomeScreens.dart';
import 'package:coba1/size_config.dart';
import 'package:coba1/utils/constants.dart';

class Signform extends StatefulWidget {
  @override
  _Signform createState() => _Signform();
}

class _Signform extends State<Signform> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildUserName(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildUserPass(),
          GestureDetector(
            onTap: () {
              print("Lupa Password Tapped");
            },
            child: Text(
              "Lupa Password",
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          isLoading
              ? CircularProgressIndicator()
              : DefaultButtonCustomeColor(
                  color: const Color.fromARGB(255, 213, 84, 19),
                  text: "Sign In",
                  press: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      setState(() {
                        isLoading = true;
                      });

                      // Simulasi login tanpa API
                      await Future.delayed(Duration(seconds: 2));

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login simulasi berhasil!')),
                      );

                      Navigator.pushNamed(context, Homescreens.routeName);

                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                ),
        ],
      ),
    );
  }

  TextFormField buildUserName() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      style: mTitleStyle,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Masukkan Email',
        labelStyle: TextStyle(
          color: focusNode.hasFocus ? mTitleColor : kPrimaryColor,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
      onSaved: (newValue) => email = newValue!,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email tidak boleh kosong';
        }
        return null;
      },
    );
  }

  TextFormField buildUserPass() {
    return TextFormField(
      obscureText: true,
      style: mTitleStyle,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Masukkan Password',
        labelStyle: TextStyle(
          color: focusNode.hasFocus ? mTitleColor : kPrimaryColor,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
      onSaved: (newValue) => password = newValue!,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong';
        }
        if (value.length < 6) {
          return 'Password minimal 6 karakter';
        }
        return null;
      },
    );
  }
}
