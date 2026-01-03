import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_touch/customer_main_screen.dart';
import 'package:magic_touch/fetch_data.dart';
import 'cart_manager.dart';

class OnlineBankingPage extends StatefulWidget {
  final String bookingRef;

  OnlineBankingPage({required this.bookingRef});

  @override
  _OnlineBankingPageState createState() => _OnlineBankingPageState();
}

class _OnlineBankingPageState extends State<OnlineBankingPage> {
  final List<String> banks = [
    "Maybank",
    "CIMB Bank",
    "RHB Bank",
    "Public Bank",
    "Hong Leong Bank",
    "Bank Islam",
  ];

  String? selectedBank; // store user's choice
  double totalAmount = CartManager.instance.getTotal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Show a redirect popup simulating bank processing
  void _showRedirectPopup(String bank) {
    showDialog(
      context: context,
      barrierDismissible: false, // user cannot dismiss manually
      builder: (context) {
        // Close the popup after 2 seconds
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // close popup
          _saveToFirestoreAndClearCart(); // then save to Firestore
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF6A688E)),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  "Redirecting to $bank's secure payment portal...",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Save cart to Firestore and clear it
  Future<void> _saveToFirestoreAndClearCart() async {
    if (selectedBank == null) return;

    final userData = await getUserData();
    final cartItems = CartManager.instance.selectedItems;

    try {
      for (var item in cartItems) {
        await _firestore.collection('appointments').add({
          'email': userData?['email'] ?? '',
          'date': item['date'],
          'time': item['time'],
          'serviceName': item['name'],
          'name': userData?["name"] ?? '',
          'status': 'Upcoming',
          'paymentMethod': selectedBank,
          'bookingRef': widget.bookingRef,
          'amount': totalAmount,
        });
      }

      // Clear cart
      CartManager.instance.clearCart();

      // Show confirmation dialog
      _showConfirmationDialog();
    } catch (e) {
      print("Error saving to Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save payment. Try again.")),
      );
    }
  }

  /// Confirmation dialog with redirect to main screen
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text("Payment Recorded"),
        content: Text(
          "Your payment via $selectedBank has been recorded.\nBooking Ref: ${widget.bookingRef}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => CustomerMainScreen()),
                    (route) => false,
              );
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("Online Banking"),
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Bank dropdown
            DropdownButtonFormField<String>(
              value: selectedBank,
              hint: Text("Select Bank"),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: banks
                  .map((bank) => DropdownMenuItem(
                value: bank,
                child: Text(bank),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBank = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Total amount display
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF6A688E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Total Amount: RM ${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(height: 30),

            // Pay button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedBank == null
                    ? null
                    : () => _showRedirectPopup(selectedBank!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A688E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Mark as Paid",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
