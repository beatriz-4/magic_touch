import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StaffAppointmentPage extends StatefulWidget {
  const StaffAppointmentPage({super.key});

  @override
  State<StaffAppointmentPage> createState() => _StaffAppointmentPageState();
}

class _StaffAppointmentPageState extends State<StaffAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedTab = "upcoming";

  // Helper to format date display
  String _formatDateDisplay(String dateStr) {
    try {
      List<String> parts = dateStr.split('-');
      DateTime date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return DateFormat("dd MMM yyyy").format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Helper to format time display (convert 24h to 12h with AM/PM)
  String _formatTimeDisplay(String time24) {
    try {
      List<String> parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
      final hours = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
      final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hours:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  // Helper to format time range
  String _formatTimeRange(String time) {
    try {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      TimeOfDay startTime = TimeOfDay(hour: hour, minute: minute);
      TimeOfDay endTime = TimeOfDay(hour: hour + 1 > 23 ? 23 : hour + 1, minute: 0);

      final startHours = startTime.hourOfPeriod == 0 ? 12 : startTime.hourOfPeriod;
      final startPeriod = startTime.period == DayPeriod.am ? 'AM' : 'PM';

      final endHours = endTime.hourOfPeriod == 0 ? 12 : endTime.hourOfPeriod;
      final endPeriod = endTime.period == DayPeriod.am ? 'AM' : 'PM';

      return '$startHours:${minute.toString().padLeft(2, '0')} $startPeriod - $endHours:00 $endPeriod';
    } catch (e) {
      return time;
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Appointment Details"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("Name", appt["name"] ?? "-"),
              _detailRow("Email", appt["email"] ?? "_"),
              _detailRow("Booking Ref", appt["bookingRef"] ?? "-"),
              _detailRow("Service", appt["serviceName"] ?? "-"),
              _detailRow("Date", _formatDateDisplay(appt["date"] ?? "")),
              _detailRow("Time", _formatTimeRange(appt["time"] ?? "")),
              _detailRow("Payment Method", appt["paymentMethod"] ?? "-"),
              _detailRow("Amount", "RM ${(appt["amount"] ?? 0).toStringAsFixed(2)}"),
              _detailRow("Status", (appt["status"] ?? "").toUpperCase()),
              if (appt["cancelledAt"] != null)
                _detailRow(
                  "Cancelled At",
                  DateFormat("dd MMM yyyy HH:mm").format(
                    (appt["cancelledAt"] as Timestamp).toDate(),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (_selectedTab == "upcoming")
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Mark as Completed'),
                    content: const Text(
                      'Mark this appointment as completed?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _firestore
                      .collection('appointments')
                      .doc(appt['id'])
                      .update({
                    'status': 'completed',
                    'completedAt': Timestamp.now(),
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment marked as completed'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text("Mark Completed"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String title, String value) {
    final bool isSelected = _selectedTab == value;

    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF6A688E) : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          setState(() {
            _selectedTab = value;
          });
        },
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Appointment List"),
        backgroundColor: const Color(0xFFF2F7E2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ================= TABS =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _tabButton("Upcoming", "upcoming"),
                const SizedBox(width: 8),
                _tabButton("Completed", "completed"),
                const SizedBox(width: 8),
                _tabButton("Cancelled", "cancelled"),
              ],
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('appointments')
                  .where('status', isEqualTo: _selectedTab)
                  .orderBy('date')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No appointments",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var appt = doc.data() as Map<String, dynamic>;
                    appt['id'] = doc.id;

                    return GestureDetector(
                      onTap: () => _showAppointmentDetails(appt),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // TIME
                            Container(
                              width: 80,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A688E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _formatTimeDisplay(appt["time"] ?? ""),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A688E),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateDisplay(appt["date"] ?? "")
                                        .split(' ')[0], // Just day
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // SERVICE & BOOKING INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appt["serviceName"] ?? "Service",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Ref: ${appt["bookingRef"] ?? "-"}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    appt["paymentMethod"] ?? "-",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // AMOUNT & ARROW
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "RM ${(appt["amount"] ?? 0).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF294D32),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}