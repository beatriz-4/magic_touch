import 'package:flutter/material.dart';

class StaffHelpSupportPage extends StatefulWidget {
  @override
  _StaffHelpSupportPageState createState() => _StaffHelpSupportPageState();
}

class _StaffHelpSupportPageState extends State<StaffHelpSupportPage> {
  // Lists of help items
  List<ExpansionItem> items = [
    ExpansionItem(
        header: "Frequently Asked Questions (FAQ)",
        body:
        "• How can I view the status of the customer's booking?\n"
            "Authorized staff can use the 'Appointment list' feature to view the upcoming, completed and cancelled booking.\n\n"
            "• Can I change service prices or durations?\n"
            "Yes, through the 'Content Management' interface, you can add, edit or delete service details. The system includes safeguards to prevent accidental deletions."
 ),
    ExpansionItem(
        header: "Tutorial: Daily Operation Management",
        body:
        "1. Secure Login: Enter your Company Code, Staff ID/Email, and Password to access administrative features.\n"
            "2. Dashboard Review: Check the 'Monthly Overview' to see total appointments, top services and performance indicators.\n"
            "3. Schedule Monitoring: Use the 'Appointment List' to view upcoming service types and specific customer details.\n"
            "4. Posting Announcements: To update customers on promotions or maintenance, use the 'Post Notice' form. Choose the post type, add a description and set a schedule.\n"
            "5. Quality Control: Navigate to the 'Feedback List' to review filterable customer ratings and comments linked to completed appointments.\n"
            "6. Session Safety: Always use the 'Logout' button to revoke your secure session token when finished."

    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("Help & Support Centre"),
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF669292),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Only takes height needed
            children: items
                .map(
                  (item) => ExpansionTile(
                title: Text(
                  item.header,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item.body,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class ExpansionItem {
  String header;
  String body;

  ExpansionItem({required this.header, required this.body});
}
