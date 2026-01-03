import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PromotionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7E2),
      appBar: AppBar(
        title: Text(
          "Promotions & Announcements",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3E1F),
          ),
        ),
        backgroundColor: Color(0xFFF2F7E2),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC280A2),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text(
                    "Error loading notices",
                    style: TextStyle(fontSize: 16, color: Color(0xFF2D3E1F)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Show only the "no notices" message now
            return Center(
              child: Text(
                "No active notices at the moment",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3E1F),
                ),
              ),
            );
          }

          final notices = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notices.length + 2, // +2 for the two default images at top
            itemBuilder: (context, index) {
              // Show default images first
              if (index == 0) {
                return Column(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          "assets/images/MagicTouch-Logo-Promotion.png",
                          width: 175,
                          height: 106,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                );
              }

              if (index == 1) {
                return Column(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          "assets/images/MagicTouch-Poster-Promotion.png",
                          width: 325,
                          height: 459,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                            child:
                            Divider(thickness: 1.5, color: Color(0xFFC280A2))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "LATEST UPDATES",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC280A2),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(
                            child:
                            Divider(thickness: 1.5, color: Color(0xFFC280A2))),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],
                );
              }

              // Show Firebase notices
              final doc = notices[index - 2];
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'] ?? 'Announcement';
              final description = data['description'] ?? '';
              final fileUrl = data['fileUrl'];
              final fileName = data['fileName'] ?? '';
              final scheduleDate = data['scheduleDate'] != null
                  ? (data['scheduleDate'] as Timestamp).toDate()
                  : null;

              final isPromotion = type == 'Promotion';
              final cardColor = isPromotion ? Color(0xFFC280A2) : Color(0xFF9896C7);
              final lightCardColor =
              isPromotion ? Color(0xFFF5E6ED) : Color(0xFFE8E7F3);
              final iconData = isPromotion
                  ? Icons.local_offer_rounded
                  : Icons.campaign_rounded;
              final typeLabel = isPromotion ? 'PROMOTION' : 'ANNOUNCEMENT';

              return Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with type badge and icon
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightCardColor,
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
                              color: cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              iconData,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                color: cardColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ),
                          if (scheduleDate != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: cardColor,
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
                                  Text(
                                    DateFormat('dd MMM yyyy').format(scheduleDate),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: TextStyle(
                              color: Color(0xFF2D3E1F),
                              fontSize: 14,
                              height: 1.6,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (fileUrl != null && _isImageFile(fileName))
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  fileUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF2F7E2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image_rounded,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Image unavailable",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          if (fileUrl != null && !_isImageFile(fileName))
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: InkWell(
                                onTap: () => _openFile(fileUrl),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: lightCardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: cardColor.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "PDF Attachment",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: cardColor,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "Tap to view",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: cardColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool _isImageFile(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png'].contains(ext);
  }

  void _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
