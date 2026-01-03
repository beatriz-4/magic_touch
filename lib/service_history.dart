import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'fetch_data.dart';

class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Service History"),
        backgroundColor: const Color(0xFFF2F7E2),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserData(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text("No user data found"));
          }

          final userData = userSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('appointments')
                .where('email', isEqualTo: userData['email'])
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (!orderSnapshot.hasData ||
                  orderSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No service history",
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }

              final orders = orderSnapshot.data!.docs;

              return ListView(
                padding: EdgeInsets.symmetric(vertical: 16),
                children: [
                  // 🔹 LATEST UPDATES HEADER
                  SizedBox(height: 24),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1.5,
                            color: Color(0xFFC280A2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "LATEST SERVICES",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC280A2),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1.5,
                            color: Color(0xFFC280A2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // 🔹 Your original info tiles
                  ...orders.map((doc) {
                    return _buildInfoTile(
                      doc['serviceName'],
                      doc['date'],
                      doc['time'],
                      doc['bookingRef'],
                      doc['paymentMethod'],
                      doc['amount'],
                      doc['status'],
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(
      String serviceName,
      String date,
      String time,
      String ref,
      String paymentMethod,
      double amount,
      String status,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // FIRST ROW - GREEN BACKGROUND
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFBBD9B0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFBBD9B0), // same green
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.greenAccent,
                    size: 22,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    serviceName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6),
                      Row(
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            " (${time})",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SECOND COLUMN / CONTENT - WHITE BACKGROUND
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // prevents stretching
              children: [
                Text(
                  "Booking Ref: ${ref}",
                  style: TextStyle(
                    color: Color(0xFF2D3E1F),
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  "Payment Method: ${paymentMethod}",
                  style: TextStyle(
                    color: Color(0xFF2D3E1F),
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  "Amount: RM${amount}",
                  style: TextStyle(
                    color: Color(0xFF2D3E1F),
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  "Status: ${status}",
                  style: TextStyle(
                    color: Color(0xFF2D3E1F),
                    fontSize: 14,
                    height: 1.6,
                    letterSpacing: 0.2,
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
