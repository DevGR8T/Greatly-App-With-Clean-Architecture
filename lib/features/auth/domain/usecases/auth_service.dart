import 'package:dartz/dartz.dart';
import 'package:greatly_user/core/error/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/user.dart';
import 'check_email_verfication_status_usecase.dart';
import 'get_current_user_usecase.dart';
import 'logout_usecase.dart';
import 'login_with_email_usecase.dart';
import 'register_with_email_usecase.dart';
import 'login_with_google_usecase.dart';
import 'login_with_apple_usecase.dart';
import 'register_with_google_usecase.dart';
import 'register_with_apple_usecase.dart';
import 'send_password_reset_email_usecase.dart';
import 'send_email_verification_usecase.dart';

class AuthService {
  final LoginWithEmailUseCase loginWithEmailUseCase;
  final RegisterWithEmailUseCase registerWithEmailUseCase;
  final LogoutUseCase logoutUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LoginWithAppleUseCase loginWithAppleUseCase;
  final RegisterWithGoogleUseCase registerWithGoogleUseCase;
  final RegisterWithAppleUseCase registerWithAppleUseCase;
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final CheckEmailVerificationStatusUseCase checkEmailVerificationStatusUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthService({
    required this.loginWithEmailUseCase,
    required this.registerWithEmailUseCase,
    required this.logoutUseCase,
    required this.loginWithGoogleUseCase,
    required this.loginWithAppleUseCase,
    required this.registerWithGoogleUseCase,
    required this.registerWithAppleUseCase,
    required this.sendPasswordResetEmailUseCase,
    required this.sendEmailVerificationUseCase,
    required this.checkEmailVerificationStatusUseCase,
     required this.getCurrentUserUseCase,
  });

  Future<Either<Failure, User>> loginWithEmail(String email, String password) {
    return loginWithEmailUseCase(email, password);
  }

  Future<Either<Failure, User>> registerWithEmail(
      String email, String password,
      {String? username, String? phone}) {
    return registerWithEmailUseCase(email, password, username: username, phone: phone);
  }

  Future<Either<Failure, User>> loginWithGoogle() {
    return loginWithGoogleUseCase();
  }

  Future<Either<Failure, User>> loginWithApple() {
    return loginWithAppleUseCase();
  }

  Future<Either<Failure, User>> registerWithGoogle() {
    return registerWithGoogleUseCase();
  }

  Future<Either<Failure, User>> registerWithApple() {
    return registerWithAppleUseCase();
  }

  Future<void> logout() {
    return logoutUseCase();
  }

  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    return sendPasswordResetEmailUseCase(email);
  }

  Future<void> sendEmailVerification() {
    return sendEmailVerificationUseCase();
  }

  Future<Either<Failure, bool>> checkEmailVerificationStatus() {
    return checkEmailVerificationStatusUseCase();
  }


Future<bool> isFirstLoginAfterVerification(String userId) async {
  try {
    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();
    
    // Create a unique key for this user's verification status
    final key = 'user_${userId}_has_logged_in_after_verification';
    
    // Check if this is the first login (key doesn't exist or is false)
    final isFirstLogin = !(prefs.getBool(key) ?? false);
    
    // If it's the first login, update the preference to true for future checks
    if (isFirstLogin) {
      await prefs.setBool(key, true);
    }
    
    return isFirstLogin;
  } catch (e) {
    print('Error in isFirstLoginAfterVerification: $e');
    // Default to false if there's an error (skip onboarding)
    return false;
  }
}
}





//IF PREFERABLY TO USE FIRESTORE TO TRACK FIRST LOGIN USE THE CODE BELOW

// Future<bool> isFirstLoginAfterVerification(String userId) async {
//   try {
//     final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    
//     // Check if document exists
//     if (!userDoc.exists) {
//       // Create the document first
//       await FirebaseFirestore.instance.collection('users').doc(userId).set({
//         'hasLoggedInAfterVerification': true
//       });
//       return true; // First login
//     }
    
//     final isFirstLogin = !(userDoc.data()?['hasLoggedInAfterVerification'] ?? false);
    
//     if (isFirstLogin) {
//       await FirebaseFirestore.instance.collection('users').doc(userId).update({
//         'hasLoggedInAfterVerification': true
//       });
//     }
    
//     return isFirstLogin;
//   } catch (e) {
//     print('Error in isFirstLoginAfterVerification: $e');
//     return false;
//   }
// }