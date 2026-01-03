import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_touch/customer_main_screen.dart';
import 'cart_manager.dart';
import 'fetch_data.dart'; // Make sure you import CartManager

class CashPaymentPage extends StatelessWidget {
  final String bookingRef;
  CashPaymentPage({required this.bookingRef});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalAmount = CartManager.instance.getTotal();


  Future<void> _saveToFirestoreAndClearCart(BuildContext context) async {
    final cartItems = CartManager.instance.selectedItems;
    final userData = await getUserData();
    try {
      // Save each item to Firestore
      for (var item in cartItems) {
        await _firestore.collection('appointments').add({
          'email': userData?['email'],
          'date': item['date'],
          'time': item['time'],
          'serviceName': item['name'],
          'name':userData?["name"],
          'status': 'Upcoming',
          'paymentMethod': 'Cash',
          'bookingRef': bookingRef,
          'amount': totalAmount,
        });
      }

      // Clear the cart
      CartManager.instance.clearCart();

      // Show confirmation
      _showCashConfirmation(context);
    } catch (e) {
      print('Error saving to Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save order. Try again.')),
      );
    }
  }


  void _showCashConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          "Cash Payment Submitted",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Thank you! Please proceed to the counter to complete your payment.",
          style: TextStyle(fontSize: 15),
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("Cash Payment"),
        centerTitle: true,
        backgroundColor: Color(0xFFF2F7E2),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Booking Reference",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                bookingRef,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 30),
            Icon(
              Icons.attach_money_rounded,
              size: 100,
              color: Color(0xFF6A688E),
            ),
            SizedBox(height: 20),
            Text(
              "Please bring your booking reference and pay at the counter to complete your transaction.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => _saveToFirestoreAndClearCart(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6A688E),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Mark as Paid",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
