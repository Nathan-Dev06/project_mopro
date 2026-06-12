import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../user_profile.dart';

class UserService {
  static Future<void> loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (data == null) return;

    UserProfile.name = data['name'] ?? '';
    UserProfile.email = data['email'] ?? '';
    UserProfile.phone = data['phone'] ?? '';
    UserProfile.address = data['address'] ?? '';
    UserProfile.isAdmin = data['isAdmin'] ?? false;
  }
}