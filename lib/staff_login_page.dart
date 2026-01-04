import 'package:flutter/material.dart';
import 'package:magic_touch/signIn_with_google.dart';
import 'email_service.dart';
import 'staff_main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffLoginPage extends StatefulWidget {
  @override
  _StaffLoginPageState createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final companyCodeController = TextEditingController();
  final staffIdController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleAuthService _authService = GoogleAuthService();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Manual login
  Future<void> loginStaff() async {
    String companyCode = companyCodeController.text.trim();
    String staffId = staffIdController.text.trim();
    String password = passwordController.text;

    if (companyCode.isEmpty || staffId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: staffId,
        password: password,
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists &&
          userDoc['role'] == 'staff' &&
          userDoc['companyCode'] == companyCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful!")),
        );

        await EmailService.sendEmail(
          recipient: userCredential.user!.email!,
          subject: "Welcome!",
          message: "Hello ${userDoc['name']}, you have successfully logged in as staff.",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StaffMainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid credentials or not staff.")),
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

  // Google login
  Future<void> loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-in cancelled.")),
        );
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc['role'] == 'staff') {
        await EmailService.sendEmail(
          recipient: user.email!,
          subject: "Welcome!",
          message: "Hello ${user.displayName}, you have successfully logged in as staff.",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StaffMainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This Google account is not registered as staff.")),
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
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Staff Login"),
        backgroundColor: const Color(0xFFF2F7E2),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: companyCodeController,
                decoration: InputDecoration(
                  labelText: "Company Code",
                  filled: true,
                  fillColor: Color(0xFFBBD9B0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: staffIdController,
                decoration: InputDecoration(
                  labelText: "Staff ID or Email",
                  filled: true,
                  fillColor: Color(0xFFBBD9B0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : loginStaff,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(0xFF688E73),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Or continue with",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              // Google Sign-In button styled like manual login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.white,
                    elevation: 3,
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google.png',
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text("Sign in with Google", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
