import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Handles storing user details in Firestore.
class AuthFirestoreDataSource {
  final FirebaseFirestore _firestore;

  /// Initializes the Firestore instance.
  AuthFirestoreDataSource(this._firestore);

  /// Saves user details to the 'users' collection in Firestore.
  Future<void> storeUserDetails(User user, {String? name, String? email, String? phone}) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid, // User's unique ID
      'name': name ?? user.displayName, // User's name
      'email': email ?? user.email, // User's email
      'phone': phone, // User's phone number
      'createdAt': FieldValue.serverTimestamp(), // Timestamp of creation
    });
  }
}