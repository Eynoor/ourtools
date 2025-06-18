import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> identitas(String phoneNumber, bool isPhoneVerified, String faceVerificationImage) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/isiData'); // Change 127.0.0.1 to 10.0.2.2 for Android Emulator.

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'is_phone_verified': isPhoneVerified,
        'face_verification_image': faceVerificationImage,
      }),
    );

    if (response.statusCode == 201) {
      print('Identitas registered successfully!');
    } else if (response.statusCode == 422) {
      final errors = jsonDecode(response.body);
      if (errors['error'] != null) {
        print('Validation failed: ${errors['error']}');
      } else {
        print('Validation failed: ${errors.toString()}');
      }
    } else {
      print('Failed to register user: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
