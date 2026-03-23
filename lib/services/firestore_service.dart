import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  /// WRITE USER DATA
  Future<void> saveUserData() async {
    final user = auth.currentUser;

    if (user == null) return;

    await db.collection('users').doc(user.uid).set({
      'email': user.email,
      'lastLogin': DateTime.now(),
    });
  }

  /// READ USER DATA
  Future<Map<String, dynamic>?> getUserData() async {
    final user = auth.currentUser;

    if (user == null) return null;

    final doc =
    await db.collection('users').doc(user.uid).get();

    return doc.data();
  }
}