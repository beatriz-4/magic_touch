import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:magic_touch/main.dart';
import 'customer_profile_page.dart';
import 'service_appointment_page.dart';
import 'feedback_page.dart';
import 'appointment_page.dart';
import 'ai_chatbot_page.dart';
import 'settings_page.dart';
import 'fetch_data.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  String userRole = "guest"; // default
  int _currentIndex = 1; // Home default

  // Auto sliding images
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> imageList = [
    'assets/images/Homepage1.png',
    'assets/images/Homepage2.png',
    'assets/images/Homepage3.png',
  ];

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Not signed in → guest
      setState(() {
        userRole = "guest";
      });
    } else {
      // Signed in → fetch role
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

    // Auto-slide images
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < imageList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  // 🔥 Navigation Handler for bottom nav
  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    // SETTINGS
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }

    // HOME (No navigation needed)
    else if (index == 1) {
      print("Home tapped");
    }

    // PROFILE
    else if (index == 2) {
      if (userRole == "customer") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomerProfilePage()),
        );
      } else {
        _redirectGuestToHome();
      }
    }
  }

  // 🔥 Guest redirect helper
  void _redirectGuestToHome() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You must register or log in to access this page"),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(Duration(milliseconds: 50), () {
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

      appBar: AppBar(
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Magic Touch"),
        elevation: 0,
      ),

      body: Column(
        children: [
          // 🔥 Top Auto-Slider
          Container(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imageList[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16),

          // 🔥 GRID MENU
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 153 / 176,
                ),
                children: [
                  // SERVICE & PROMOTION
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServicesAppointmentPage(),
                        ),
                      );
                    },
                    child: _menuCard(
                      "Service & Promotion",
                      Color(0xFF6A688E),
                      Icons.local_offer,
                    ),
                  ),

                  // UPCOMING APPOINTMENT
                  InkWell(
                    onTap: () {
                      if (userRole == "guest") {
                        _redirectGuestToHome();
                      } else if (userRole == "customer") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AppointmentPage()),
                        );
                      }
                    },
                    child: _menuCard(
                      "Upcoming Appointment",
                      Color(0xFF4E70A1),
                      Icons.event_available,
                    ),
                  ),

                  // AI CHATBOT
                  InkWell(
                    onTap: () {
                      if (userRole == "guest") {
                        _redirectGuestToHome();
                      } else if (userRole == "customer") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AIChatbotPage()),
                        );
                      }
                    },
                    child: _menuCard(
                      "AI Chatbot",
                      Color(0xFFC576A0),
                      Icons.smart_toy,
                    ),
                  ),

                  // FEEDBACK
                  InkWell(
                    onTap: () {
                      if (userRole == "guest") {
                        _redirectGuestToHome();
                      } else if (userRole == "customer") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeedbackPage()),
                        );
                      }
                    },
                    child: _menuCard(
                      "Feedback & Report",
                      Color(0xFF74967D),
                      Icons.feedback,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔥 Custom Bottom Navigation Bar
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFB3B3B3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // SETTINGS
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: _currentIndex == 0 ? Colors.blueAccent : Colors.white,
                  ),
                  onPressed: () => _onNavTap(0),
                ),

                SizedBox(width: 60),

                // PROFILE
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: _currentIndex == 2 ? Colors.blueAccent : Colors.white,
                  ),
                  onPressed: () => _onNavTap(2),
                ),
              ],
            ),
          ),

          // HOME button (center circle)
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () => _onNavTap(1),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _currentIndex == 1 ? Colors.blueAccent : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.home,
                  color: _currentIndex == 1 ? Colors.white : Color(0xFF6A688E),
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Card builder
  Widget _menuCard(String title, Color color, IconData icon) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
