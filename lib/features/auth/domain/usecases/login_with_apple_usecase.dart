import 'package:dartz/dartz.dart';
import 'package:greatly_user/core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging in with Apple.
class LoginWithAppleUseCase {
  final AuthRepository authRepository;

  /// Constructor to inject the [AuthRepository].
  LoginWithAppleUseCase(this.authRepository);

  /// Executes the use case to log in with Apple.
  /// Returns [Right(User)] on success or [Left(Failure)] on error.
  Future<Either<Failure, User>> call() async {
    try {
      // Attempt to log in with Apple via the repository
      final user = await authRepository.loginWithApple();
      return Right(user); // ✅ Success
    } catch (e) {
      // Return a failure if an exception occurs
      return Left(ServerFailure('Failed to login with Apple: ${e.toString()}'));
    }
  }
}