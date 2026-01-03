import 'package:flutter/material.dart';

class ResetPasswordConfirmationPage extends StatelessWidget {
  final String email;

  ResetPasswordConfirmationPage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        backgroundColor: Color(0xFFF2F7E2)
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Reset Password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              Text(
                "Please check your email inbox, we've sent you an email containing a password recovery link:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 15),
              Text(
                email,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
