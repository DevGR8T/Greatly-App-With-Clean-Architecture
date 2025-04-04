import '../entities/user.dart';

/// Abstract class defining the contract for authentication-related operations.
abstract class AuthRepository {
  /// Logs in a user with email and password.
  /// Returns a [User] object on success.
  Future<User> loginWithEmail(String email, String password);

  /// Registers a user with email and password.
  /// Optionally accepts a [username] and [phone].
  /// Returns a [User] object on success.
  Future<User> registerWithEmail(String email, String password,
      {String? username, String? phone});

  /// Logs in a user with Google.
  /// Returns a [User] object on success.
  Future<User> loginWithGoogle();

  /// Logs in a user with Apple.
  /// Returns a [User] object on success.
  Future<User> loginWithApple();

  /// Registers a user with Google.
  /// Returns a [User] object on success.
  Future<User> registerWithGoogle();

  /// Registers a user with Apple.
  /// Returns a [User] object on success.
  Future<User> registerWithApple();

  /// Sends a password reset email to the specified [email].
  Future<void> sendPasswordResetEmail(String email);

  /// Sends an email verification link to the currently logged-in user.
  Future<void> sendEmailVerification();

  /// Checks if the currently logged-in user's email is verified.
  /// Returns `true` if verified, otherwise `false`.
  Future<bool> isEmailVerified();

  /// Signs out the currently logged-in user.
  Future<void> signOut();

  /// Retrieves the currently logged-in user, if any.
  /// Returns a [User] object or `null` if no user is logged in.
  Future<User?> getCurrentUser();
}