import 'package:coba1/components/custom_surfix_icon.dart';
import 'package:coba1/components/default_custom_button_color.dart';
import 'package:coba1/components/identitas/identitasComponent.dart';
//import 'package:coba1/screens/dataDiri/data.dart';

import 'package:coba1/size_config.dart';
import 'package:coba1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class Registerform extends StatefulWidget {
  @override
  _Registerform createState() => _Registerform();
}

class _Registerform extends State<Registerform> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk mengambil nilai input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // Controller untuk konfirmasi password

  // Fungsi untuk menampilkan dialog/snackbar
  void showSnackbar(BuildContext context, String message, bool success) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: success ? Colors.green : Colors.red,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Tambahkan key untuk validasi
      child: Column(
        children: [
          Text(
            'Sign up',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
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
          buildPass(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildConfirmPass(), // Menambahkan form untuk konfirmasi password
          DefaultButtonCustomeColor(
            color: kPrimaryColor,
            text: "Register",
            press: () async {
              // Memastikan validasi berhasil sebelum melanjutkan
              if (_formKey.currentState!.validate()) {
                // Panggil fungsi registerUser dengan data dari input
                final username = _usernameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                // Tampilkan loading sementara
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Center(child: CircularProgressIndicator());
                  },
                );

                // Panggil API
                try {
                  await registerUser(username, email, password);
                  Navigator.of(context).pop(); // Tutup dialog loading
                  showSnackbar(context, 'User berhasil didaftarkan!', true);

                  // Navigasi ke halaman home setelah berhasil daftar
                 //Navigator.pushReplacementNamed(context, MaterialPageRoute(builder: (context) => indentitasComponent()));
                 Navigator.push(context,
                 MaterialPageRoute(builder: (context) => Identitascomponent()));
                } catch (e) {
                  Navigator.of(context).pop(); // Tutup dialog loading
                  showSnackbar(context, 'Gagal mendaftar: $e', false);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildUserName() {
    return TextFormField(
      controller: _usernameController, // Controller untuk username
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Masukan Username',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
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
      controller: _emailController, // Controller untuk email
      keyboardType: TextInputType.emailAddress,
      style: mTitleStyle,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Masukan Email',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
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

  TextFormField buildPass() {
    return TextFormField(
      controller: _passwordController, // Controller untuk password
      obscureText: true,
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Masukan Password',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
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

  TextFormField buildConfirmPass() {
    return TextFormField(
      controller: _confirmPasswordController, // Controller untuk konfirmasi password
      obscureText: true,
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        labelText: 'Konfirmasi Password',
        hintText: 'Masukkan Konfirmasi Password',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Konfirmasi password tidak boleh kosong';
        } else if (value != _passwordController.text) {
          return 'Password dan konfirmasi password tidak cocok';
        }
        return null;
      },
    );
  }
}
