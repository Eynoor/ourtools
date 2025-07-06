import 'dart:convert';
import 'package:http/http.dart' as http;

// Replace with your backend API base URL
const String baseUrl = 'http://10.0.2.2:8000/api';

// Function to send WhatsApp OTP via backend API
Future<bool> sendWhatsAppOtp(String phoneNumber) async {
  final url = Uri.parse('\$baseUrl/send-whatsapp-otp');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Failed to send OTP: \${response.statusCode} - \${response.body}');
      return false;
    }
  } catch (e) {
    print('Error sending OTP: \$e');
    return false;
  }
}

// Function to verify WhatsApp OTP via backend API
Future<bool> verifyWhatsAppOtp(String phoneNumber, String otp) async {
  final url = Uri.parse('\$baseUrl/verify-whatsapp-otp');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber, 'otp': otp}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['verified'] == true;
    } else {
      print('Failed to verify OTP: \${response.statusCode} - \${response.body}');
      return false;
    }
  } catch (e) {
    print('Error verifying OTP: \$e');
    return false;
  }
}
