import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coba1/components/register/RegisterForm.dart';
import 'package:coba1/components/identitas/identitasComponent.dart';

import 'package:coba1/size_config.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('Render RegisterForm basic', (WidgetTester tester) async {
    // Simulasi ukuran layar yang lebih besar untuk menghindari overflow
    tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    // Inisialisasi SizeConfig dengan ukuran layar default
    SizeConfig.screenWidth = 1080;
    SizeConfig.screenHeight = 1920;
    SizeConfig.defaultSize = 10;
    SizeConfig.orientation = Orientation.portrait;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: RegisterForm(),
        ),
      ),
    ));

    // Pastikan semua field dan tombol ada
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('Register'), findsOneWidget);
  });
}
