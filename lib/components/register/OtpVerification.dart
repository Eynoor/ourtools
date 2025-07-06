import 'package:flutter/material.dart';
import 'package:coba1/utils/constants.dart';
import 'package:coba1/components/identitas/api_service.dart';

class OtpVerification extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerified;

  OtpVerification({required this.phoneNumber, required this.onVerified});

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  void _verifyOtp() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    bool verified = await verifyWhatsAppOtp(widget.phoneNumber, _otpController.text);

    if (verified) {
      widget.onVerified();
    } else {
      setState(() {
        _errorMessage = "Kode OTP salah, silakan coba lagi.";
        _isVerifying = false;
      });
    }
  }

  void _resendOtp() async {
    bool sent = await sendWhatsAppOtp(widget.phoneNumber);
    if (sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kode OTP telah dikirim ulang ke ${widget.phoneNumber}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim ulang kode OTP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verifikasi OTP"),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Masukkan kode OTP yang dikirim ke nomor WhatsApp ${widget.phoneNumber}"),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Kode OTP",
                errorText: _errorMessage,
              ),
            ),
            SizedBox(height: 20),
            _isVerifying
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    child: Text("Verifikasi"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                  ),
            TextButton(
              onPressed: _resendOtp,
              child: Text("Kirim ulang kode OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
