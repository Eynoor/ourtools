import 'package:coba1/components/default_custom_button_color.dart';
import 'package:coba1/components/identitas/identitasComponent.dart';
import 'package:coba1/size_config.dart';
import 'package:coba1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';  // Import api_service.dart

class Dataform extends StatefulWidget {
  @override
  _Dataform createState() => _Dataform();
}

class _Dataform extends State<Dataform> {
  // Controller for each input
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController provinsiController = TextEditingController();
  TextEditingController kotaController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();

  // Focus node for input fields
  FocusNode focusNode = FocusNode();

  // Function to save form data
  void saveFormData() {
    // Get data from controllers
    String namaAwal = firstNameController.text;
    String namaAkhir = lastNameController.text;
    String tanggalLahir = tanggalLahirController.text;
    String alamat = alamatController.text;
    String provinsi = provinsiController.text;
    String kabupaten = kotaController.text;
    String kecamatan = kecamatanController.text;

    // Call API to save data without the token
    saveData(namaAwal, namaAkhir, tanggalLahir, alamat, provinsi, kabupaten, kecamatan).then((_) {
      // Navigate to the next screen after successful data submission
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Identitascomponent()),
      );
    }).catchError((e) {
      // Show error message if data saving fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save data: $e'),
        backgroundColor: Colors.red,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Text(
            'Lengkapi Data Diri Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(50)),
          Text(
            'Nama Lengkap',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(10)),
          buildFirstName(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildLastName(),
          SizedBox(height: getProportionateScreenHeight(20)),
          Text(
            'Tanggal Lahir',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(10)),
          buildTanggalLahir(),
          SizedBox(height: getProportionateScreenHeight(10)),
          Text(
            'Alamat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Work Sans',
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(10)),
          buildProvinsi(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildKota(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildKecamatan(),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButtonCustomeColor(
            color: kPrimaryColor,
            text: "Next",
            press: saveFormData, // Call the saveFormData function
          ),
        ],
      ),
    );
  }

  TextFormField buildFirstName() {
    return TextFormField(
      controller: firstNameController,
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        hintText: 'Masukan Firstname',
        labelStyle: TextStyle(color: focusNode.hasFocus ? mTitleColor : kPrimaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildLastName() {
    return TextFormField(
      controller: lastNameController,
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        hintText: 'Masukan Lastname',
        labelStyle: TextStyle(color: focusNode.hasFocus ? mTitleColor : kPrimaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildTanggalLahir() {
    return TextFormField(
      controller: tanggalLahirController,
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        hintText: 'Masukan Tanggal Lahir',
        labelStyle: TextStyle(color: focusNode.hasFocus ? mTitleColor : kPrimaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildProvinsi() {
    return TextFormField(
      controller: provinsiController,
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        hintText: 'Provinsi',
        labelStyle: TextStyle(color: focusNode.hasFocus ? mTitleColor : kPrimaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildKota() {
    return TextFormField(
      controller: kotaController,
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        hintText: 'Kota atau Kabupaten',
        labelStyle: TextStyle(color: focusNode.hasFocus ? mTitleColor : kPrimaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildKecamatan() {
    return TextFormField(
      controller: kecamatanController,
      keyboardType: TextInputType.text,
      style: mTitleStyle,
      decoration: InputDecoration(
        hintText: 'Kecamatan',
        labelStyle: TextStyle(color: focusNode.hasFocus ? mTitleColor : kPrimaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
