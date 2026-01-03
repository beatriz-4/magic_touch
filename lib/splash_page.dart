import 'package:flutter/material.dart';
import 'main.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Auto navigate after 9 seconds
    Future.delayed(Duration(seconds: 9), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      body: Center(
        child: Image.asset(
          'assets/images/Magic_Touch.png',
          width: 363,
          height: 221,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
