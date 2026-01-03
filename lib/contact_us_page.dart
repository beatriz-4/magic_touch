import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        backgroundColor: Color(0xFFF2F7E2),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Contact Us", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF669292),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              contactItem(Icons.phone, "Phone", "+60 12-345 6789"),
              SizedBox(height: 15),
              contactItem(Icons.email, "Email", "magictouch@gmail.com"),
              SizedBox(height: 15),
              contactItem(Icons.facebook, "Facebook", "Magic Touch Salon MY"),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget contactItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text(
                value,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
