import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'feedback_details_page.dart';

class ViewFeedbackPage extends StatefulWidget {
  const ViewFeedbackPage({super.key});

  @override
  State<ViewFeedbackPage> createState() => _ViewFeedbackPageState();
}

class _ViewFeedbackPageState extends State<ViewFeedbackPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text(
          "Customer Feedback",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF2F7E2),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 FILTER CHIPS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('In Progress'),
                const SizedBox(width: 8),
                _buildFilterChip('Resolved'),
              ],
            ),
          ),

          // 🔹 FEEDBACK LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No feedback found",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final title = data['title'] ?? 'No title';
                    final customer = data['customerName'] ?? 'Anonymous';
                    final service = data['services'] ?? 'N/A';
                    final status = data['status'] ?? 'pending';
                    final rating = data['rating'] ?? 0;
                    final timestamp = data['timestamp'];

                    final date = timestamp != null
                        ? DateFormat('dd MMM yyyy, hh:mm a')
                        .format((timestamp as Timestamp).toDate())
                        : 'Unknown';

                    Color statusColor;
                    IconData statusIcon;

                    switch (status) {
                      case 'resolved':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case 'in progress':
                        statusColor = Colors.orange;
                        statusIcon = Icons.pending;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.schedule;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FeedbackDetailsPage(feedbackId: doc.id),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 HEADER
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E7F3),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF9896C7),
                                    child: Text(
                                      customer[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          service,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(statusIcon,
                                            size: 12, color: statusColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🔹 BODY
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text("$rating / 5"),
                                      const Spacer(),
                                      const Icon(Icons.access_time,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        date,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 14),
                                    ],
                                  ),
                                ],
                              ),
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

  // 🔹 FILTER CHIP
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.deepPurple,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 QUERY (NO INDEX ERROR)
  Stream<QuerySnapshot> _buildQuery() {
    final collection =
    FirebaseFirestore.instance.collection('feedback');

    if (_selectedFilter == 'All') {
      return collection
          .orderBy('timestamp', descending: true)
          .snapshots();
    }

    return collection
        .where('status',
        isEqualTo: _selectedFilter.toLowerCase())
        .snapshots();
  }
}
