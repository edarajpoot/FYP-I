import 'package:login/screens/NewPassword.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;

  OTPVerificationScreen({required this.verificationId});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage;

  // Function to verify the OTP
  Future<void> _verifyOTP() async {
    String otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP';
      });
      return;
    }

    try {
      // Create a PhoneAuthCredential with the entered OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to the reset password screen after successful OTP verification
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the OTP sent to your phone number.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
                errorText: _errorMessage,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
