import 'package:dartz/dartz.dart';
import 'package:greatly_user/core/error/failure.dart';
import 'package:greatly_user/features/auth/domain/entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging in with email and password.
class LoginWithEmailUseCase {
  final AuthRepository authRepository;

  /// Constructor to inject the [AuthRepository].
  LoginWithEmailUseCase(this.authRepository);

  /// Executes the use case to log in with email and password.
  /// Returns [Right(User)] on success or [Left(Failure)] on error.
  Future<Either<Failure, User>> call(String email, String password) async {
    try {
      // Attempt to log in with email and password via the repository
      final user = await authRepository.loginWithEmail(email, password);
      return Right(user); // ✅ Success
    } catch (e) {
      // Return a failure if an exception occurs
      return Left(ServerFailure('Failed to login: ${e.toString()}'));
    }
  }
}