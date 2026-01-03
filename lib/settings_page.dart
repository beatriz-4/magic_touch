import 'package:flutter/material.dart';
import 'customer_help_support_page.dart';
import 'staff_help_support_page.dart';
import 'about_us_page.dart';
import 'contact_us_page.dart';
import 'location_page.dart';
import 'fetch_data.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String userRole = "guest";

  @override
  void initState() {
    super.initState();
    // fetch role from Firestore
    getUserData().then((data) {
      if (data != null && data['role'] != null && data['role'] != '') {
        setState(() {
          userRole = data['role']; // "customer", "staff", etc.
        });
      } else {
        setState(() {
          userRole = "guest";
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),

      appBar: AppBar(
        backgroundColor: Color(0xFF688E73),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ABOUT US BUTTON
            _settingButton(
              title: "About Us",
              icon: Icons.info,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AboutUsPage()),
                );
              },
            ),

            SizedBox(height: 20),

            // CONTACT US BUTTON
            _settingButton(
              title: "Contact Us",
              icon: Icons.phone,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContactUsPage()),
                );
              },
            ),

            SizedBox(height: 20),

            // LOCATION BUTTON
            _settingButton(
              title: "Location",
              icon: Icons.location_on,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LocationPage()),
                );
              },
            ),

            SizedBox(height: 20),

            // HELP/SUPPORT -
            _settingButton(
              title: "Help & Support Centre",
              icon: Icons.help,
              onTap: () {
                if (userRole == "customer"||userRole == "guest") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerHelpSupportPage(),
                    ),
                  );
                } else if (userRole == "staff") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffHelpSupportPage(),
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Stylish Button
  Widget _settingButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Color(0xFF669292),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
