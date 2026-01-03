import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_touch/fetch_data.dart';
import 'payment_page.dart';
import 'cart_manager.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isAgreed = false; // for checkbox
  Map<String, dynamic>? userData;
  bool payDepositOnly = false;
  bool isLoading = true; // while fetching user data

  @override
  void initState() {
    super.initState();
    loadUserAppointmentStatus();
  }

  // Fetch userData and check appointments collection
  Future<void> loadUserAppointmentStatus() async {
    final data = await getUserData();
    setState(() {
      userData = data;
    });

    if (userData != null && userData!['email'] != null) {
      final email = userData!['email'];

      final snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('email', isEqualTo: email)
          .get();

      // If no appointment documents found → deposit only
      setState(() {
        payDepositOnly = snapshot.docs.isEmpty;
        isLoading = false;
      });
    } else {
      setState(() {
        payDepositOnly = true;
        isLoading = false;
      });
    }
  }

  double getTotal() {
    double total = CartManager.instance.selectedItems.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));

    if (payDepositOnly) return 45; // deposit only
    return total; // full total if appointment exists
  }

  @override
  Widget build(BuildContext context) {
    final items = CartManager.instance.selectedItems;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: const Color(0xFFF2F7E2),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Cart items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      item['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        'RM ${item['price'].toStringAsFixed(2)} | Date: ${item['date']} | Time: ${item['time']}'),
                    trailing: Text('Qty: ${item['quantity']}'),
                  ),
                );
              },
            ),
          ),

          // Policy Section (full original text)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.warning),
                    SizedBox(width: 4),
                    Text(
                      "Cancellation Policy",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "This is our personal space, and we truly appreciate your respect and cooperation so every visit stays comfortable and smooth for everyone.\n\n",
                  style: TextStyle(fontSize: 13),
                ),
                const Text("1.Come Solo. no extra guests or kids.", style: TextStyle(fontSize: 13)),
                const Text("2.Parking. avoid parking in front of the gate. Park along the side instead.", style: TextStyle(fontSize: 13)),
                const Text("3.Be On Time. appointments more than 10 minutes late cannot be accepted. This area can have heavy traffic, so please plan your journey ahead to arrive on time.", style: TextStyle(fontSize: 13)),
                const Text("4. Cancellations & Changes. please reschedule at least 12 hours before your appointment. Late changes or no-shows will incur a RM45 fee or deposit forfeiture & future bookings may be declined.\n\n", style: TextStyle(fontSize: 13)),
                const Text("Waxing & period:", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const Text("- It is allowed to get waxed while on your period, provided you have a tampon in. If you choose not to wax during your period, plan appointments based on your cycle to avoid last-minute cancellations fee.", style: TextStyle(fontSize: 13)),

                // I agree checkbox
                CheckboxListTile(
                  value: isAgreed,
                  onChanged: (bool? value) {
                    setState(() {
                      isAgreed = value ?? false;
                    });
                  },
                  title: const Text('I agree to the terms and conditions'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),

          // Total & Checkout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (payDepositOnly)
                          const Text(
                            'RM 45 (Deposit only)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          )
                        else
                          Text(
                            'RM ${getTotal().toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        if (payDepositOnly)
                          const Text(
                            'Remaining balance due on appointment',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Checkout button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (items.isEmpty || !isAgreed)
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PaymentPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (items.isNotEmpty && isAgreed)
                          ? const Color(0xFF6A688E)
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Checkout',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
