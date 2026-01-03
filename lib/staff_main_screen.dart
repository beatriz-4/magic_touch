import 'dart:async';
import 'package:flutter/material.dart';

import 'staff_profile_page.dart';
import 'staff_appointment_page.dart';
import 'settings_page.dart';
import 'Monthly_overview_page.dart';
import 'ViewFeedbackPage.dart';
import 'PostNoticePage.dart';
import 'ContentManagementPage.dart';

class StaffMainScreen extends StatefulWidget {
  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  int _currentIndex = 1;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> imageList = [
    "assets/images/MagicTouch-Logo-Promotion.png",
  ];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      _currentPage = (_currentPage + 1) % imageList.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SettingsPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StaffProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Staff Dashboard"),
        backgroundColor: const Color(0xFFF2F7E2),
        centerTitle: true,
        elevation: 0,
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // ---------- SLIDER ----------
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            child: PageView.builder(
              controller: _pageController,
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imageList[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ---------- MENU ----------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _menuItem(
                  title: "Monthly Overview",
                  color: const Color(0xFF6A688E),
                  icon: Icons.calendar_view_month,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MonthlyOverviewPage(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  title: "Appointment List",
                  color: const Color(0xFF4E70A1),
                  icon: Icons.list_alt,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StaffAppointmentPage(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  title: "Post Notice",
                  color: const Color(0xFF669292),
                  icon: Icons.announcement,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostNoticePage(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  title: "View Feedback",
                  color: const Color(0xFF8A6A9F),
                  icon: Icons.feedback,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewFeedbackPage(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  title: "Content Management",
                  color: const Color(0xFFB3776A),
                  icon: Icons.edit,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContentManagementPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFB3B3B3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
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
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: _currentIndex == 0
                        ? Colors.blueAccent
                        : Colors.white,
                  ),
                  onPressed: () => _onNavTap(0),
                ),
                const SizedBox(width: 60),
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: _currentIndex == 2
                        ? Colors.blueAccent
                        : Colors.white,
                  ),
                  onPressed: () => _onNavTap(2),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () => _onNavTap(1),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? Colors.blueAccent
                      : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.home,
                  size: 36,
                  color: _currentIndex == 1
                      ? Colors.white
                      : const Color(0xFF6A688E),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU CARD (289 x 64) =================
  Widget _menuItem({
    required String title,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: SizedBox(
          width: 289,
          height: 64,
          child: Card(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(icon, size: 28, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


