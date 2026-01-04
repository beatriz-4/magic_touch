import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>?> getUserData([String? uid]) async {
  uid ??= FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  final doc =
  await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (doc.exists) {
    return doc.data() as Map<String, dynamic>;
  }
  return null;
}




