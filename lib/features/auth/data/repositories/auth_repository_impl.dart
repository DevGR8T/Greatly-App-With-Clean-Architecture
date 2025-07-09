import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:greatly_user/features/auth/domain/entities/user.dart';
import 'package:greatly_user/features/auth/domain/repositories/auth_repository.dart';
import '../../../../core/utils/error_utils.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../datasources/remote/auth_firestore_data_source.dart';

/// Handles all authentication-related tasks.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource; // Handles Firebase Auth actions.
  final AuthFirestoreDataSource _authFirestoreDataSource; // Saves user details in Firestore.

  /// Constructor to initialize authentication sources.
  AuthRepositoryImpl(this._authRemoteDataSource, this._authFirestoreDataSource);

  /// Logs in a user with email and password.
  @override
  Future<User> loginWithEmail(String email, String password) async {
    final firebase_auth.User? firebaseUser =
        await _authRemoteDataSource.signInWithEmail(email, password);
    if (firebaseUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'login-failed',
        message: 'Login failed. Please check your credentials.',
      );
    }
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: firebaseUser.displayName,
      phone: firebaseUser.phoneNumber,
      isNewUser: false,
      emailVerified: firebaseUser.emailVerified, 
    );
  }

  /// Registers a new user, then saves their details in Firestore.
  @override
  Future<User> registerWithEmail(String email, String password,
      {String? username, String? phone}) async {
    final firebase_auth.User? firebaseUser =
        await _authRemoteDataSource.registerWithEmail(email, password);
    if (firebaseUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'registration-failed',
        message: 'Registration failed. Please try again.',
      );
    }
    await _authFirestoreDataSource.storeUserDetails(
      firebaseUser,
      name: username,
      phone: phone,
    );
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: username,
      phone: phone, isNewUser: false, emailVerified: firebaseUser.emailVerified,
    );
  }

  /// Logs out the user.
  @override
  Future<void> signOut() async {
    await _authRemoteDataSource.signOut();
  }

  /// Logs in a user using Google authentication.
  @override
  Future<User> loginWithGoogle() async {
    final firebase_auth.User? firebaseUser =
        await _authRemoteDataSource.signInWithGoogle();
    if (firebaseUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'google-login-failed',
        message: 'Google login failed. Please try again.',
      );
    }
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: firebaseUser.displayName,
      phone: firebaseUser.phoneNumber,
      isNewUser: false,
      emailVerified: firebaseUser.emailVerified, 
    );
  }

  /// Logs in a user using Apple authentication.
  @override
  Future<User> loginWithApple() async {
    final firebase_auth.User? firebaseUser =
        await _authRemoteDataSource.signInWithApple();
    if (firebaseUser == null) {
      throw firebase_auth.FirebaseAuthException(
        code: 'apple-login-failed',
        message: 'Apple login failed. Please try again.',
      );
    }
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: firebaseUser.displayName,
      phone: firebaseUser.phoneNumber,
      isNewUser: false,
      emailVerified: firebaseUser.emailVerified, // Add the required argument
    );
  }

  /// Registers a new user using Google authentication, then saves their details in Firestore.
  @override
  @override
Future<User> registerWithGoogle() async {
  // Perform Google sign-in and get the Firebase user and additional user info
  final firebase_auth.UserCredential userCredential =
      await _authRemoteDataSource.registerWithGoogle();

  final firebase_auth.User? firebaseUser = userCredential.user;
  final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

  if (firebaseUser == null) {
    throw Exception('Google registration failed');
  }

  // Store user details in Firestore
  await _authFirestoreDataSource.storeUserDetails(
    firebaseUser,
    name: firebaseUser.displayName,
    email: firebaseUser.email,
  );

  // Return the User object with the isNewUser property
  return User(
    id: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    username: firebaseUser.displayName,
    phone: firebaseUser.phoneNumber,
    isNewUser: isNewUser, // Populate the isNewUser property
    emailVerified: firebaseUser.emailVerified,
  );
}

  /// Registers a new user using Apple authentication, then saves their details in Firestore.
  @override
Future<User> registerWithApple() async {
  final firebase_auth.User? firebaseUser =
      await _authRemoteDataSource.registerWithApple();
  if (firebaseUser == null) {
    throw Exception('Apple registration failed');
  }

  // Store user details in Firestore
  await _authFirestoreDataSource.storeUserDetails(
    firebaseUser,
    name: firebaseUser.displayName,
    email: firebaseUser.email,
  );

  // Return the User object with isNewUser defaulted to false
  return User(
    id: firebaseUser.uid,
    email: firebaseUser.email ?? '',
    username: firebaseUser.displayName,
    phone: firebaseUser.phoneNumber,
    isNewUser: false, emailVerified: firebaseUser.emailVerified, // Default to false for Apple sign-in
  );
}

@override
Future<void> sendPasswordResetEmail(String email) async {
  try {
    // Try fetching the user by email
    var userRecord = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase()) // Ensure lowercase matching
        .get();

    if (userRecord.docs.isEmpty) {
      // Throw a specific error
      throw Exception('Email address not found.');
    }

    // Send the reset link
    await _authRemoteDataSource.sendPasswordResetEmail(email);
  } on firebase_auth.FirebaseAuthException catch (e) {
    // Use ErrorUtils to clean up the error message
    throw Exception(ErrorUtils.cleanErrorMessage(e.message ?? ''));
  } catch (e) {
    // Log the error for debugging


    // Use ErrorUtils to clean up the error message
    throw Exception(ErrorUtils.cleanErrorMessage(e.toString()));
  }
}




  /// Retrieves the currently logged-in user.
  @override
  Future<User?> getCurrentUser() async {
    final firebase_auth.User? firebaseUser =
        await _authRemoteDataSource.getCurrentUser();
    if (firebaseUser == null) {
      return null;
    }
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: firebaseUser.displayName,
      phone: firebaseUser.phoneNumber,
      isNewUser: false,
      emailVerified: firebaseUser.emailVerified, // Add the required argument
    );
  }

  /// Sends an email verification link to the user.
  @override
  Future<void> sendEmailVerification() async {
    final firebase_auth.User? firebaseUser =
        await _authRemoteDataSource.getCurrentUser();
    if (firebaseUser == null) {
      throw Exception('No user is currently logged in');
    }
    if (!firebaseUser.emailVerified) {
      await firebaseUser.sendEmailVerification();
    }
  }

  /// Checks if the user's email is verified.
  @override
  Future<bool> isEmailVerified() async {
    final firebase_auth.User? firebaseUser =
        await _authRemoteDataSource.getCurrentUser();
    if (firebaseUser == null) {
      throw Exception('No user is currently logged in');
    }
    await firebaseUser.reload(); // Reload user to get updated verification status
    return firebaseUser.emailVerified;
  }
}