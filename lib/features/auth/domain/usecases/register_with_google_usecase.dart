import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithGoogleUseCase {
  final AuthRepository authRepository;

  RegisterWithGoogleUseCase(this.authRepository);

  Future<Either<Failure, User>> call() async {
    try {
      final user = await authRepository.registerWithGoogle();
      return Right(user); // Success
    } catch (e) {
      return Left(ServerFailure('Failed to register with Google: ${e.toString()}')); //  Error
    }
  }
}
