import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'fetch_data.dart';

class AppointmentPage extends StatefulWidget {
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage>
    with SingleTickerProviderStateMixin {
  DateTime fromDate = DateTime.now().subtract(Duration(days: 30));
  DateTime toDate = DateTime.now();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<List<QueryDocumentSnapshot>> _getFilteredAppointments(
      String status, String userEmail) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('email', isEqualTo: userEmail)
        .where('status', isEqualTo: status)
        .get();

    // Convert Timestamp to DateTime and filter by fromDate & toDate
    return snapshot.docs.where((doc) {
      DateTime appointmentDate;
      try {
        appointmentDate =
            (doc['date'] as Timestamp).toDate();
      } catch (_) {
        appointmentDate =
            DateTime.tryParse(doc['date']) ?? DateTime.now();
      }
      return appointmentDate.isAfter(fromDate.subtract(Duration(days: 1))) &&
          appointmentDate.isBefore(toDate.add(Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text("My Appointments"),
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserData(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return Center(child: Text("No user data found"));
          }
          final userData = userSnapshot.data!;
          final userEmail = userData['email'];

          return Column(
            children: [
              // Floating date picker row
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fromDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() {
                            fromDate = picked;
                          });
                        }
                      },
                      child: Text(
                          "From: ${DateFormat('dd MMM yyyy').format(fromDate)}"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: toDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() {
                            toDate = picked;
                          });
                        }
                      },
                      child: Text(
                          "To: ${DateFormat('dd MMM yyyy').format(toDate)}"),
                    ),
                  ],
                ),
              ),

              // Tabs for statuses
              TabBar(
                controller: _tabController,
                labelColor: Colors.indigo,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Color(0xFF6A688E),
                tabs: [
                  Tab(text: "Upcoming"),
                  Tab(text: "Completed"),
                  Tab(text: "Cancelled"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: ["Upcoming", "Completed", "Cancelled"]
                      .map((status) => FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _getFilteredAppointments(status, userEmail),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: Text("Loading..."));
                      }
                      if (snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            "No $status appointments",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data![index];

                          DateTime scheduleDate;
                          try {
                            scheduleDate =
                                (doc['date'] as Timestamp).toDate();
                          } catch (_) {
                            scheduleDate =
                                DateTime.tryParse(doc['date']) ??
                                    DateTime.now();
                          }

                          return _buildAppointmentCard(
                            doc['serviceName'],
                            scheduleDate,
                            doc['time'],
                            doc['bookingRef'],
                            doc['paymentMethod'],
                            doc['amount'],
                            doc['status'],
                          );
                        },
                      );
                    },
                  ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
      String serviceName,
      DateTime date,
      String time,
      String ref,
      String paymentMethod,
      double amount,
      String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: status == "Upcoming"
                  ? Color(0xFFBBD9B0)
                  : status == "Completed"
                  ? Color(0xFF8EC0E4)
                  : Color(0xFFF5AFAE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.history,
                    size: 22,
                    color: status == "Upcoming"
                        ? Colors.greenAccent
                        : status == "Completed"
                        ? Colors.blueAccent
                        : Colors.redAccent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    serviceName,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 13, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        "${DateFormat('dd MMM yyyy').format(date)} ($time)",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Card body
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booking Ref: $ref"),
                Text("Payment Method: $paymentMethod"),
                Text("Amount: RM$amount"),
                Text("Status: $status"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
