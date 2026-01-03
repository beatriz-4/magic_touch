import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_manager.dart';
import 'fetch_data.dart';

class OnlineBankingPage extends StatefulWidget {
  final String bookingRef;

  const OnlineBankingPage({super.key, required this.bookingRef});

  @override
  State<OnlineBankingPage> createState() => _OnlineBankingPageState();
}

class _OnlineBankingPageState extends State<OnlineBankingPage> {
  final List<Map<String, dynamic>> banks = [
    {"name": "Maybank", "logo": "assets/banks/maybank.png", "color": const Color(0xFFFFD700)},
    {"name": "CIMB Bank", "logo": "assets/banks/cimb.png", "color": const Color(0xFFDC143C)},
    {"name": "RHB Bank", "logo": "assets/banks/rhb.png", "color": const Color(0xFF0047AB)},
    {"name": "Public Bank", "logo": "assets/banks/public.png", "color": const Color(0xFF8B008B)},
    {"name": "Bank Islam", "logo": "assets/banks/bankislam.png", "color": const Color(0xFF008000)},
  ];

  double totalAmount = CartManager.instance.getTotal();
  bool isProcessing = false;

  // Create appointments from cart items
  Future<void> _createAppointmentsFromCart(String bank) async {
    final cartItems = CartManager.instance.selectedItems;
    final userData = await getUserData();

    for (var item in cartItems) {
      String date = item['date'] ?? '';
      String time = item['time'] ?? '';
      String serviceId = item['id'] ?? '';
      String serviceName = item['name'] ?? '';
      double price = item['price'] ?? 0.0;

      if (date.isEmpty || time.isEmpty || serviceId.isEmpty) continue;

      await FirebaseFirestore.instance.collection('appointments').add({
        'email': userData?['email'] ?? '',
        'name': userData?['name'] ?? '',
        'bookingRef': widget.bookingRef,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'date': date,
        'time': time,
        'status': 'Upcoming',
        'paymentMethod': 'Online Banking - $bank',
        'amount': price,
        'createdAt': Timestamp.now(),
      });
    }

    // Clear the cart
    CartManager.instance.clearCart();
  }

  // Handle payment process
  Future<void> _processPayment(BuildContext context, String bank) async {
    if (CartManager.instance.selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your cart is empty."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isProcessing) return;
    setState(() => isProcessing = true);

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text("Redirecting to bank...")),
            ],
          ),
        ),
      );
    }

    try {
      // Simulate bank redirect delay
      await Future.delayed(const Duration(seconds: 2));

      // Create appointments
      await _createAppointmentsFromCart(bank);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text("Payment Successful"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booking Reference: ${widget.bookingRef}"),
                const SizedBox(height: 8),
                Text("Payment Method: Online Banking - $bank"),
                const SizedBox(height: 8),
                const Text("Status: Completed"),
                const SizedBox(height: 12),
                const Text(
                  "Your appointments have been created and are now in 'Upcoming'.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error processing payment: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Online Banking"),
        backgroundColor: const Color(0xFFF2F7E2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Booking reference card
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  const Text(
                    "Booking Reference:",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.bookingRef,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Select your bank to proceed with payment:",
              style: TextStyle(fontSize: 16),
            ),
          ),

          // Bank list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: banks.length,
              itemBuilder: (context, index) {
                final bank = banks[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    enabled: !isProcessing,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          bank["logo"],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: bank["color"],
                              child: const Icon(
                                Icons.account_balance,
                                color: Colors.white,
                                size: 28,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    title: Text(
                      bank["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      "Online Banking",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isProcessing ? Colors.grey : Colors.black87,
                    ),
                    onTap: () => _processPayment(context, bank["name"]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
