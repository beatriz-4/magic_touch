import 'package:flutter/material.dart';
import 'fetch_data.dart';

class CustomerProfileEditPage extends StatefulWidget {
  @override
  _CustomerProfileEditPageState createState() =>
      _CustomerProfileEditPageState();
}

class _CustomerProfileEditPageState extends State<CustomerProfileEditPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void saveProfile() {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile Updated Successfully!")),
    );
  }

  Widget buildField(String label, TextEditingController controller,
      {bool obscure = false, bool readOnly = false, VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Color(0xFF688E73),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(1, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),

      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: Color(0xFF688E73),
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
          future: getUserData(), // fetch all user data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text("No user data found"));
            }
            final userData = snapshot.data!;
            // Initialize controllers with userData
            nameController.text = userData['name'] ?? '';
            emailController.text = userData['email'] ?? '';
            phoneController.text = userData['phone'] ?? '';
            dobController.text = userData['birthday'] ?? '';

            return SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  buildField("Name", nameController),
                  buildField("Email", emailController),
                  buildField("Phone", phoneController),

                  buildField(
                    "Date of Birth",
                    dobController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1990, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        dobController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate
                            .year}";
                      }
                    },
                  ),

                  buildField("Password", passwordController, obscure: true),
                  buildField("Confirm Password", confirmPasswordController,
                      obscure: true),

                  SizedBox(height: 10),

                  // SAVE BUTTON
                  ElevatedButton(
                    onPressed: saveProfile,
                    child: Text("Save Changes", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF688E73),
                      minimumSize: Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),

            );
          },
      ),
    );
  }
}

