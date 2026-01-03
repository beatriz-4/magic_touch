import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
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
        title: Text("About Us", style: TextStyle(color: Colors.black)),
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
          child: Text(
            "Magic Touch Salon offers professional beauty, hair, and wellness "
                "services with experienced stylists and premium products.\n\n"
                "We aim to provide a relaxing and luxurious experience to all "
                "our customers.",
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}
