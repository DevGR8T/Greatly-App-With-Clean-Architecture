import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository authRepository;

  LoginWithGoogleUseCase(this.authRepository);

  Future<Either<Failure, User>> call() async {
    try {
      final user = await authRepository.loginWithGoogle();
      return Right(user); // Success
    } catch (e) {
      return Left(ServerFailure('Failed to login with Google: ${e.toString()}')); // Error
    }
  }
}
