import 'package:flutter/material.dart';
import 'package:magic_touch/signIn_with_google.dart';
import 'package:magic_touch/signup_page.dart';
import 'forgot_password_page.dart';
import 'customer_main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_service.dart';

class CustomerLoginPage extends StatefulWidget {
  @override
  _CustomerLoginPageState createState() => _CustomerLoginPageState();
}

class _CustomerLoginPageState extends State<CustomerLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleAuthService _authService = GoogleAuthService();

  // Manual email/password login
  Future<void> loginCustomer() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch Firestore document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc['role'] == 'customer') {
        // Send notification email
        await EmailService.sendEmail(
          recipient: userDoc['email'],
          subject: "Welcome Back!",
          message: "Hello ${userDoc['name']}, you have logged in successfully.",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful!")),
        );

        // Navigate to CustomerMainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerMainScreen()),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Access denied: Not a customer account.")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Google Sign-In
  Future<void> loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      User? user = await _authService.signInWithGoogle();

      if (user == null) return;

      // Check Firestore document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Account exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful!")),
        );

        // Navigate to CustomerMainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerMainScreen()),
        );

        // Send notification email
        await EmailService.sendEmail(
          recipient: userDoc['email'],
          subject: "Welcome Back!",
          message: "Hello ${userDoc['name']}, you have logged in successfully.",
        );

      } else {
        // Create new Firestore document for Google account
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName ?? '',
          'role': 'customer',
        });

        // Send welcome email
        await EmailService.sendEmail(
          recipient: user.email!,
          subject: "Welcome!",
          message: "Hello ${user.displayName}, your account has been created.",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account created. Please log in.")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email Address",
                filled: true,
                fillColor: Color(0xFFBBD9B0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Color(0xFFBBD9B0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Color(0xFF688E73), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : loginCustomer,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Color(0xFF688E73),
                  elevation: 5,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Next"),
              ),
            ),
            SizedBox(height: 30),
            Text("Or continue with", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : loginWithGoogle,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.white,
                  elevation: 3,
                  side: BorderSide(color: Colors.grey),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/google.png',
                      height: 24,
                    ),
                    SizedBox(width: 10),
                    Text("Sign in with Google", style: TextStyle(color: Colors.black)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignUpPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(color: Color(0xFF688E73)),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Register Now",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
