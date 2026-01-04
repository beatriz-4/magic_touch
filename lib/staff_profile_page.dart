import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:magic_touch/main.dart';
import 'fetch_data.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("Staff Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFF2F7E2),
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
            userData?['name'] = "Brenda";
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // -------------------- LOGO --------------------
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(
                        Icons.person, size: 70, color: Colors.grey[700]),
                  ),

                  SizedBox(height: 20),
                  Text(
                    "${userData['name']}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "${userData['email']}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),

                  SizedBox(height: 20),

                  // -------------------- PROFILE INFORMATION --------------------
                  _buildInfoTile("Staff ID", "01"),
                  _buildInfoTile("Position", "Customer Support"),
                  _buildInfoTile("Phone Number", "+60 12-345 6789"),
                  _buildInfoTile("Company Code", "MagicTouch123"),

                  SizedBox(height: 25),


                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => HomePage()),
                      );
                    },
                    child: Text("Logout", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
          ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      padding: EdgeInsets.all(18),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
