import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>?> getUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null; // user not logged in

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  if (doc.exists) {
    final data = doc.data()!;
    return {
      'name': data['name'] ?? '',
      'email': data['email'] ?? '',
      'birthday': data['birthday'] ?? '',
      'phone': data['phone'] ?? '',
      'role': data['role']?? '',
    };
  }

  return null; // user document not found
}



