// lib/core/network/protected_api_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../error/exceptions.dart';

class ProtectedApiService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Checks if the user is authenticated before proceeding with an API call
  Future<void> ensureAuthenticated() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('User not authenticated');
    }
    
    // Optional: Check if token is about to expire and refresh if needed
    try {
      await user.getIdToken(true);
    } catch (e) {
      throw AuthException('Failed to refresh authentication token');
    }
  }
}