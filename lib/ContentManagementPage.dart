import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_service_page.dart';
import 'EditServicePage.dart';

class ContentManagementPage extends StatefulWidget {
  @override
  State<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends State<ContentManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _hasInitialized = false;

  // Your original hardcoded services
  final List<Map<String, dynamic>> hardcodedServices = [
    {
      "type": "Services",
      "name": "Brow Shaping/Brow Wax",
      "duration": "20 mins",
      "price": 65.0,
    },
    {
      "type": "Services",
      "name": "Brow Tint & Shaping",
      "duration": "40 mins",
      "price": 165.0,
    },
    {
      "type": "Services",
      "name": "Brow Lamination & Shaping",
      "duration": "1 hour",
      "price": 205.0,
    },
    {
      "type": "Services",
      "name": "Brow Lamination, Tint & Shaping",
      "duration": "1 hour 15 mins",
      "price": 250.0,
    },
    {
      "type": "Services",
      "name": "Full Face Wax & Brow Shaping",
      "duration": "30 mins",
      "price": 145.0,
    },
    {
      "type": "Services",
      "name": "Around the Lip Wax",
      "duration": "10 mins",
      "price": 30.0,
    },
    {
      "type": "Services",
      "name": "Upper Lip Wax",
      "duration": "15 mins",
      "price": 25.0,
    },
    {
      "type": "Services",
      "name": "Sideburn Wax",
      "duration": "15 mins",
      "price": 40.0,
    },
    {
      "type": "Services",
      "name": "Chin Wax",
      "duration": "10 mins",
      "price": 25.0,
    },
    {
      "type": "Services",
      "name": "Back of Neck",
      "duration": "20 mins",
      "price": 45.0,
    },
    {
      "type": "Services",
      "name": "Under arms Wax",
      "duration": "15 mins",
      "price": 40.0,
    },
    {
      "type": "Services",
      "name": "Brazillian & Inner Thigh Wax",
      "duration": "30 mins",
      "price": 199.0,
    },
    {
      "type": "Services",
      "name": "Belly Wax",
      "duration": "25 mins",
      "price": 60.0,
    },
    {
      "type": "Services",
      "name": "Half Legs",
      "duration": "30 mins",
      "price": 89.0,
    },
    {
      "type": "Services",
      "name": "Full Legs",
      "duration": "40 mins",
      "price": 165.0,
    },
    {
      "type": "Package",
      "name": "4x Brazilian Package (Shareable)",
      "duration": "30 mins",
      "price": 600.0,
    },
    {
      "type": "Package",
      "name": "8x Brazilian Package (Shareable)",
      "duration": "30 mins",
      "price": 1160.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeFirebaseData();
  }

  // Copy hardcoded services to Firebase on first launch
  Future<void> _initializeFirebaseData() async {
    try {
      final snapshot = await _firestore.collection('services').get();

      // If Firebase is empty, copy all hardcoded services to Firebase
      if (snapshot.docs.isEmpty) {
        print('Initializing Firebase with hardcoded services...');

        for (var service in hardcodedServices) {
          await _firestore.collection('services').add({
            'type': service['type'],
            'name': service['name'],
            'duration': service['duration'],
            'price': service['price'],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        print('Firebase initialized successfully!');
      }

      setState(() {
        _hasInitialized = true;
      });
    } catch (e) {
      print('Error initializing Firebase: $e');
      setState(() {
        _hasInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Content Management"),
        backgroundColor: const Color(0xFFF2F7E2),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('services').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No services available. Initializing...'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final service = doc.data() as Map<String, dynamic>;
                final serviceId = doc.id;

                return Card(
                  color: const Color(0xFF6A688E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    title: Text(
                      service["name"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "${service["duration"]} | RM ${service["price"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditServicePage(
                              serviceId: serviceId,
                              type: service["type"] ?? "",
                              name: service["name"] ?? "",
                              price: (service["price"] ?? 0).toDouble(),
                              duration: service["duration"] ?? "",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddServicePage()),
              );
            },
            child: const Text(
              "Add New Service",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}


