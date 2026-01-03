import 'package:flutter/material.dart';
import 'cash_payment_page.dart';
import 'online_banking_page.dart';
import 'qr_payment_page.dart';
import 'dart:math';
class PaymentPage extends StatelessWidget {
  // Function to generate a booking reference number
  String generateBookingRef() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
            (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final bookingRef = generateBookingRef(); // generate once for this payment session
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("Payment Options"),
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnlineBankingPage(
                      bookingRef: bookingRef,
                    ),
                  ),
                );
              },
              child: Text("Online Banking"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRPaymentPage(
                      bookingRef: bookingRef,
                    ),
                  ),
                );
              },
              child: Text("QR Code"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.purpleAccent,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CashPaymentPage(
                      bookingRef: bookingRef,
                    ),
                  ),
                );
              },
              child: Text("Cash"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}