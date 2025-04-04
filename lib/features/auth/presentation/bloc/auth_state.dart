import 'package:equatable/equatable.dart';
import 'package:greatly_user/features/auth/domain/entities/user.dart';

/// Base class for all authentication states.
/// It extends Equatable to help Flutter compare states efficiently.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => []; // No properties in the base class.
}

/// State when the app just starts, before any login attempt.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when the app is processing login/signup (e.g., showing a loading spinner).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when the user has successfully logged in.
class AuthLoggedIn extends AuthState {
  final User user; // Strongly typed user model

  const AuthLoggedIn({required this.user});

  @override
  List<Object?> get props => [user]; // Compare user for equality.
}

/// State when the user has successfully registered.
class AuthRegistered extends AuthState {
  final User user; // Strongly typed user model

  const AuthRegistered({required this.user});

  @override
  List<Object?> get props => [user]; // Compare user for equality.
}

/// State when a new user is detected (e.g., after social login).
class AuthNewUser extends AuthState {
  final User user; // Strongly typed user model

  const AuthNewUser({required this.user});

  @override
  List<Object?> get props => [user]; // Compare user for equality.
}

/// State when an existing user is detected (e.g., after social login).
class AuthExistingUser extends AuthState {
  final User user; // Strongly typed user model

  const AuthExistingUser({required this.user});

  @override
  List<Object?> get props => [user]; // Compare user for equality.
}

/// State when there is an error (e.g., wrong password, network failure).
class AuthError extends AuthState {
  final String message; // Stores the error message to display.

  const AuthError(this.message);

  @override
  List<Object?> get props => [message]; // Compare error messages for equality.
}

/// State when a password reset email has been sent.
class AuthPasswordResetEmailSent extends AuthState {
  const AuthPasswordResetEmailSent();
}

/// State when an email verification link has been sent.
class AuthEmailVerificationSent extends AuthState {
  const AuthEmailVerificationSent();
}

/// State when the user's email is verified.
class AuthEmailVerified extends AuthState {
  const AuthEmailVerified();
}

/// State when the user's email is not verified.
class AuthEmailNotVerified extends AuthState {
  const AuthEmailNotVerified();
}