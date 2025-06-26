import 'package:coba1/components/custom_surfix_icon.dart';
import 'package:coba1/components/default_custom_button_color.dart';
import 'package:coba1/components/identitas/identitasComponent.dart';
import 'package:coba1/size_config.dart';
import 'package:coba1/utils/constants.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk mengambil nilai input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController  = TextEditingController();

  void showSnackbar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // helper untuk style InputDecoration dengan hintText
  InputDecoration _buildInputDecoration({
    required String hint,
    required String svgIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      suffixIcon: CustomSurffixIcon(svgIcon: svgIcon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            'Sign up',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontFamily: 'Kameron',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(50)),
          buildUserName(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildEmail(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPassword(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildConfirmPassword(),
          SizedBox(height: getProportionateScreenHeight(30)),
          DefaultButtonCustomeColor(
            color: kPrimaryColor,
            text: "Register",
            press: () {
              if (_formKey.currentState!.validate()) {
                showSnackbar('Registrasi berhasil!', true);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Identitascomponent(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildUserName() {
    return TextFormField(
      controller: _usernameController,
      decoration: _buildInputDecoration(
        hint: 'Username',
        svgIcon: "assets/icons/User.svg",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Username tidak boleh kosong';
        }
        return null;
      },
    );
  }

  TextFormField buildEmail() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _buildInputDecoration(
        hint: 'Email',
        svgIcon: "assets/icons/Mail.svg",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email tidak boleh kosong';
        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Masukkan email yang valid';
        }
        return null;
      },
    );
  }

  TextFormField buildPassword() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: _buildInputDecoration(
        hint: 'Password',
        svgIcon: "assets/icons/Lock.svg",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong';
        } else if (value.length < 6) {
          return 'Password minimal 6 karakter';
        }
        return null;
      },
    );
  }

  TextFormField buildConfirmPassword() {
    return TextFormField(
      controller: _confirmController,
      obscureText: true,
      decoration: _buildInputDecoration(
        hint: 'Konfirmasi Password',
        svgIcon: "assets/icons/Lock.svg",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Konfirmasi password tidak boleh kosong';
        } else if (value != _passwordController.text) {
          return 'Password dan konfirmasi tidak cocok';
        }
        return null;
      },
    );
  }
}