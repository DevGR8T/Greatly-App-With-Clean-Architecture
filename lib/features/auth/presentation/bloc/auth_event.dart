import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => []; // No values to compare in the base class.
}

/// Event for logging in with email and password.
class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmail({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password]; // Compare email and password for equality.
}

/// Event for signing up with email, password, username, and phone number.
class RegisterWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String? username;
  final String phone;

  const RegisterWithEmail({
    required this.email,
    required this.password,
    this.username,
    required this.phone,
  });

  @override
  List<Object?> get props => [email, password, username, phone]; // Compare all fields.
}

/// Event for logging in with Google.
class LoginWithGoogle extends AuthEvent {
  const LoginWithGoogle();
}

/// Event for logging in with Apple.
class LoginWithApple extends AuthEvent {
  const LoginWithApple();
}

/// Event for registering with Google.
class RegisterWithGoogle extends AuthEvent {
  const RegisterWithGoogle();
}

/// Event for registering with Apple.
class RegisterWithApple extends AuthEvent {
  const RegisterWithApple();
}

/// Event for logging out.
class SignOut extends AuthEvent {
  const SignOut();
}

/// Event for sending a password reset email.
class ForgotPassword extends AuthEvent {
  final String email;

  const ForgotPassword({
    required this.email,
  });

  @override
  List<Object?> get props => [email]; // Compare email for equality.
}

/// Event for sending an email verification link.
class SendEmailVerification extends AuthEvent {
  const SendEmailVerification();
}

/// Event for checking the email verification status.
class CheckEmailVerificationStatus extends AuthEvent {
  const CheckEmailVerificationStatus();
}