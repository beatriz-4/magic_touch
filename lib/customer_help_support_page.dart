import 'package:flutter/material.dart';

class CustomerHelpSupportPage extends StatefulWidget {
  @override
  _CustomerHelpSupportPageState createState() => _CustomerHelpSupportPageState();
}



class _CustomerHelpSupportPageState extends State<CustomerHelpSupportPage> {


  // Lists of help items
  List<ExpansionItem> items = [
    ExpansionItem(
        header: "Frequently Asked Questions (FAQ)",
        body:

        "• How do I create an account?\n"
            "Sign up using your email is available. A Two-Factor Authentication(2FA) will be sent to secure your account before login.\n\n"
            "• How do I confirm my appointment?\n"
            "After selecting a slot, you must complete the payment (deposit or full) and upload your proof of payment. The status will then update to 'Upcoming'.\n\n"
            "• What can the AI Chatbot do?\n"
            "The chatbot uses Natural Language Processing to answer common questions about opening hours, services, and policies instantly."),
    ExpansionItem(
        header: "Tutorial: How to Book a Service",
        body:
            "1. Login/Sign-Up: Securely enter your credentials or verify via OTP.\n"
            "2. Browse Services: Navigate to the 'Services and Promotion' page to view eyebrow, wax or training options with prices and durations.\n"
            "3. Select Slot: View real-time availability and select your preferred date and time.\n"
            "4. Reserve: Tap 'Submit' to reserve the slot; it will be marked as 'Held'.\n"
            "5. Payment: Choose either to: Scan the QR code and upload your proof of payment/ online banking / cash payment.\n"
            "6. Confirmation: Once verified, you will receive an automated confirmation notification ."),
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
