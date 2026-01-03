import 'package:flutter/material.dart';
import 'package:magic_touch/signIn_with_google.dart';
import 'component/square_tile.dart';
import 'forgot_password_page.dart';
import 'staff_main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fetch_data.dart';

class StaffLoginPage extends StatefulWidget {
  @override
  _StaffLoginPageState createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final companyCodeController = TextEditingController();
  final staffIdController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

    setState(() {
      _isLoading = true;
    });

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StaffMainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid credentials or role.")),
        );
      }
    } catch (e) {
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
        title: Text("Login"),
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: Column(
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
                  SizedBox(height: 20),
                  TextField(
                    controller: staffIdController,
                    decoration: InputDecoration(
                      labelText: "Staff ID or Email Address",
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
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                            color: Color(0xFF688E73), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : loginStaff,
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
                  SizedBox(height: 70),
                  Row(
                    children: [
                      Expanded(
                          child:
                          Divider(thickness: 1.5, color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                          child:
                          Divider(thickness: 1.5, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height:50),
                  SquareTile(
                      imagePath: 'assets/images/google.png',
                      onTap: () =>GoogleAuthService().signInWithGoogle()
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