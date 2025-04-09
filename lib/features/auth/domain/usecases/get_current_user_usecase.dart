import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for retrieving the currently logged-in user.
class GetCurrentUserUseCase {
  final AuthRepository authRepository;

  /// Constructor to inject the [AuthRepository].
  GetCurrentUserUseCase(this.authRepository);

  /// Executes the use case to retrieve the current user.
  /// Returns [Right(User?)] on success or [Left(Failure)] on error.
  Future<Either<Failure, User?>> call() async {
    try {
      // Fetch the current user from the repository
      final user = await authRepository.getCurrentUser();
      return Right(user); // Success
    } catch (e) {
      // Return a failure if an exception occurs
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }
}