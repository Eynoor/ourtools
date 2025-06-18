import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> registerUser(String username, String email, String password) async {
  final url = Uri.parse('http://10.0.2.2:8000/api/register'); // Change 127.0.0.1 to 10.0.2.2 for Android Emulator.

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': password, // Make sure you send the confirmation password
      }),
    );

    if (response.statusCode == 201) {
      print('User registered successfully!');
    } else if (response.statusCode == 422) {
      // Validation failed
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
