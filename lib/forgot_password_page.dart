import 'package:flutter/material.dart';
import 'reset_password_confirmation_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your email.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email via Firebase
      await _auth.sendPasswordResetEmail(email: email);

      // On success, navigate to confirmation page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordConfirmationPage(email: email),
        ),
      );
    } catch (e) {
      // Handle errors (e.g., invalid email, user not found)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
        title: Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please enter your email address to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 100),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Enter your email",
                filled: true,
                fillColor: Color(0xFFBBD9B0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : resetPassword,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Color(0xFFBBD9B0), // Match theme
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Reset Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}