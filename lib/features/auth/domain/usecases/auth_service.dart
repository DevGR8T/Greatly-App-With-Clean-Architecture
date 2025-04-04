import 'package:dartz/dartz.dart';
import 'package:greatly_user/core/error/failure.dart';
import '../entities/user.dart';
import 'check_email_verfication_status_usecase.dart';
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
}