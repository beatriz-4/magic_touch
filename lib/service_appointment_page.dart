import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:magic_touch/main.dart';
import 'promotion_page.dart';
import 'cart_page.dart';
import 'fetch_data.dart';
import 'cart_manager.dart'; // ✅ import CartManager

class ServicesAppointmentPage extends StatefulWidget {
  const ServicesAppointmentPage({super.key});

  @override
  State<ServicesAppointmentPage> createState() =>
      _ServicesAppointmentPageState();
}

class _ServicesAppointmentPageState extends State<ServicesAppointmentPage> {
  String userRole = "guest"; // default
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late List<int> counters;
  late List<Map<String, dynamic>> selectedServices;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int currentServiceIndex = 0;

  List<Map<String, dynamic>> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedServices = [];
    _loadServicesFromFirebase();

    // fetch role from Firestore
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

  Future<void> _loadServicesFromFirebase() async {
    try {
      final snapshot = await _firestore
          .collection('services')
          .orderBy('name')
          .get();

      final loadedServices = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'duration': data['duration'] ?? '',
          'price': (data['price'] ?? 0).toDouble(),
          'type': data['type'] ?? 'Services',
        };
      }).toList();

      setState(() {
        services = loadedServices;
        counters = List.filled(services.length, 0);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading services: $e');
      setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void addToCart(int index, String dateStr, String timeStr) {
    setState(() {
      counters[index] = 1;
      final service = services[index];

      final existingIndex = selectedServices
          .indexWhere((item) => item['id'] == service['id']);

      if (existingIndex != -1) {
        selectedServices[existingIndex]['quantity'] = 1;
        selectedServices[existingIndex]['date'] = dateStr;
        selectedServices[existingIndex]['time'] = timeStr;
      } else {
        selectedServices.add({
          ...service,
          'quantity': 1,
          'date': dateStr,
          'time': timeStr,
        });
      }

      // ✅ Save globally to CartManager
      CartManager.instance.selectedItems = List.from(selectedServices);
    });
  }

  // ---------------- Shared time slot availability ----------------
  Future<List<String>> getAvailableTimes(DateTime date) async {
    List<String> allTimes = [];
    for (int hour = 9; hour < 19; hour++) {
      allTimes.add('${hour.toString().padLeft(2, '0')}:00');
    }

    try {
      String dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final snap = await _firestore
          .collection('appointments')
          .where('date', isEqualTo: dateStr)
          .where('status', whereIn: ['upcoming', 'completed'])
          .get();

      final bookedTimes = snap.docs.map((d) => d['time'] as String).toList();

      return allTimes.where((t) => !bookedTimes.contains(t)).toList();
    } catch (e) {
      print('Error fetching available times: $e');
      return allTimes;
    }
  }

  // ---------------- Keep pickTime & pickDate unchanged ----------------
  Future<void> pickTime(int index) async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final availableTimes = await getAvailableTimes(selectedDate!);

    if (!mounted || availableTimes.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No Available Times'),
          content: const Text('No available times for the selected date.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    currentServiceIndex = index; // store current service index

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          children: [
            const Text(
              'Select a Time Slot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF294D32),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                itemCount: availableTimes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                itemBuilder: (context, i) {
                  final start = int.parse(availableTimes[i].split(':')[0]);
                  final end = start + 1;
                  final display =
                      '${start.toString().padLeft(2, '0')}:00 - ${end.toString().padLeft(2, '0')}:00';
                  final isSelected = selectedTime != null &&
                      selectedTime!.hour == start &&
                      selectedTime!.minute == 0;

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? const Color(0xFF294D32)
                          : const Color(0xFF6A688E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedTime = TimeOfDay(hour: start, minute: 0);
                      });

                      // ✅ Use _formatDate and _formatTime to pass strings
                      final dateStr = _formatDate(selectedDate);
                      final timeStr = _formatTime(selectedTime);

                      addToCart(currentServiceIndex, dateStr, timeStr);
                      Navigator.pop(context);
                    },
                    child: Text(
                      display,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickDate(int index) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDate = picked;
      });
      pickTime(index);
    }
  }

  void clearCart() {
    setState(() {
      counters = List.filled(services.length, 0);
      selectedServices.clear();
      CartManager.instance.clearCart(); // ✅ clear global cart too
    });
  }

  void handleGuestRedirect() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You must register or log in to access this page"),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Services & Promotions"),
        backgroundColor: const Color(0xFFF2F7E2),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF294D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PromotionPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF688E73),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Promotion",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: clearCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Clear Cart",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : services.isEmpty
                ? const Center(
              child: Text(
                'No services available',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  color: const Color(0xFF6A688E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      service['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "${service['duration']} | RM ${service['price'].toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => pickDate(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6A688E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        counters[index] == 0
                            ? "+"
                            : counters[index].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A688E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: CartManager.instance.selectedItems.isEmpty
                ? null
                : () {
              if (userRole == "guest") {
                handleGuestRedirect();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              } else if (userRole == "customer") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(),
                  ),
                );
              }
            },
            child: Text(
              CartManager.instance.selectedItems.isEmpty
                  ? "Cart is Empty"
                  : "View Cart (${CartManager.instance.selectedItems.length})",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
