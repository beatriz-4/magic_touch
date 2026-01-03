import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:magic_touch/customer_main_screen.dart';
import 'package:magic_touch/fetch_data.dart';
import 'cart_manager.dart'; // your singleton cart manager

class QRPaymentPage extends StatefulWidget {
  final String bookingRef;
  const QRPaymentPage({super.key, required this.bookingRef});

  @override
  _QRPaymentPageState createState() => _QRPaymentPageState();
}

class _QRPaymentPageState extends State<QRPaymentPage> {
  File? _receipt;
  final ImagePicker _picker = ImagePicker();
  // Get the total amount from CartManager
  double totalAmount = CartManager.instance.getTotal();

  Future<void> _pickReceipt() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receipt = File(image.path);
      });
    }
  }
  Future<void> _confirmPayment() async {
    final userData = await getUserData();
    if (_receipt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a receipt first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      final cartItems = CartManager.instance.selectedItems;
      // Save each service to Firestore
      for (var item in cartItems) {
        await _firestore.collection('appointments').add({
          'email': userData?['email'] ?? '',
          'date': item['date'],
          'time': item['time'],
          'serviceName': item['name'],
          'name': userData?["name"] ?? '',
          'status': 'Upcoming',
          'paymentMethod': 'QR',
          'bookingRef': widget.bookingRef,
          'amount': totalAmount,
        });
      }

      // Clear cart
      CartManager.instance.clearCart();

      // Show confirmation popup
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            "Booking Ref: ${widget.bookingRef}\nYour payment has been submitted",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
                      (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error saving services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save payment. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("QR Payment"),
        backgroundColor: const Color(0xFFF2F7E2),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Booking Ref: ${widget.bookingRef}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A688E),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/Qr.jpeg',
                  width: 120,
                  height: 120,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Upload Payment Receipt",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickReceipt,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF6A688E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _receipt == null ? "Upload Receipt" : "Receipt Uploaded",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_receipt != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _receipt!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: CartManager.instance.selectedItems.isEmpty
                    ? null
                    : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A688E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm Payment",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
