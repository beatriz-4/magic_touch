import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_touch/component/square_tile.dart';
import 'package:magic_touch/customer_login_page.dart';
import 'package:magic_touch/customer_main_screen.dart';
import 'package:magic_touch/signIn_with_google.dart';
import 'email_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GoogleAuthService _authService = GoogleAuthService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final birthdayController = TextEditingController();

  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        phoneController.text.isEmpty ||
        birthdayController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Send Firebase verification email
      await userCredential.user!.sendEmailVerification();

      // Store user info in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'birthday': birthdayController.text.trim(),
        'role': 'customer',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created! Check email to verify.")),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() =>
      birthdayController.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF688E73),
      labelStyle: const TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Sign Up"),
        centerTitle: true,
        backgroundColor: const Color(0xFF688E73),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Name
              TextField(
                controller: nameController,
                decoration: _inputDecoration("Full Name"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Phone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Phone Number"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Email
              TextField(
                controller: emailController,
                decoration: _inputDecoration("Email"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Birthday
              TextField(
                controller: birthdayController,
                readOnly: true,
                onTap: _pickDate,
                decoration: _inputDecoration("Birthday").copyWith(
                    suffixIcon:
                    const Icon(Icons.calendar_today, color: Colors.white)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: _inputDecoration("Password"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: _inputDecoration("Confirm Password"),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF688E73),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // OR Divider
              const Row(
                children: [
                  Expanded(
                      child: Divider(thickness: 1.5, color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Or continue with",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  Expanded(
                      child: Divider(thickness: 1.5, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 35),

              // Google Sign-In Button
              SquareTile(
                imagePath: 'assets/images/google.png',
                onTap: () async {
                  User? user = await _authService.signInWithGoogle();

                  if (user != null && mounted) {
                    // Send notification email after Google login
                    await EmailService.sendEmail(
                      recipient: user.email!,
                      subject: "Welcome to MagicTouch!",
                      message:
                      "Hello ${user.displayName}, you have successfully logged in.",
                    );

                    // Navigate to main screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CustomerMainScreen()),
                    );
                  }
                },
              ),

              const SizedBox(height: 35),

              // Navigate to Login
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CustomerLoginPage())),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Color(0xFF688E73)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
