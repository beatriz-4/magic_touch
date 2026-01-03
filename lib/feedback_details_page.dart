import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackDetailsPage extends StatefulWidget {
  final String feedbackId;

  const FeedbackDetailsPage({required this.feedbackId, super.key});

  @override
  State<FeedbackDetailsPage> createState() => _FeedbackDetailsPageState();
}

class _FeedbackDetailsPageState extends State<FeedbackDetailsPage> {
  final TextEditingController _replyController = TextEditingController();
  Map<String, dynamic>? _feedbackData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeedback();
  }

  Future<void> _fetchFeedback() async {
    final doc = await FirebaseFirestore.instance
        .collection('feedback')
        .doc(widget.feedbackId)
        .get();

    if (doc.exists) {
      setState(() {
        _feedbackData = doc.data();
        _isLoading = false;
      });
    }
  }

  // 🔹 SUBMIT REPLY → SET IN PROGRESS
  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty) return;

    final feedbackRef = FirebaseFirestore.instance
        .collection('feedback')
        .doc(widget.feedbackId);

    // Add reply
    await feedbackRef.collection('replies').add({
      'reply': _replyController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'staffId': 'staff@example.com',
    });

    // 🔥 UPDATE STATUS
    await feedbackRef.update({
      'status': 'in progress',
    });

    _replyController.clear();

    // Refresh UI
    _fetchFeedback();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reply sent. Status set to In Progress")),
    );
  }

  // 🔹 RESOLVE BUTTON
  Future<void> _resolveFeedback() async {
    await FirebaseFirestore.instance
        .collection('feedback')
        .doc(widget.feedbackId)
        .update({
      'status': 'resolved',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback resolved")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_feedbackData == null) {
      return const Scaffold(
        body: Center(child: Text("Feedback not found")),
      );
    }

    final status = _feedbackData!['status'];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Feedback Details"),
        backgroundColor: const Color(0xFFF2F7E2),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 FEEDBACK INFO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCEC5D7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow("Title", _feedbackData!['title'] ?? ''),
                  _detailRow("Status", status),
                  _detailRow("Customer", _feedbackData!['customerName'] ?? ''),
                  _detailRow("Service", _feedbackData!['services'] ?? ''),
                  _detailRow("Description", _feedbackData!['description'] ?? ''),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 REPLY SECTION (disabled if resolved)
            if (status != 'resolved')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCEC5D7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Reply",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _replyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Type your reply...",
                        filled: true,
                        fillColor: const Color(0xFFA1A1CE),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7474b0)),
                          onPressed: _submitReply,
                          child: const Text("Submit Reply"),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: _resolveFeedback,
                          child: const Text("Mark as Resolved"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (status == 'resolved')
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  "This feedback has been resolved.",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
