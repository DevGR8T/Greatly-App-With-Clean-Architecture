import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithAppleUseCase {
  final AuthRepository authRepository;

  RegisterWithAppleUseCase(this.authRepository);

  Future<Either<Failure, User>> call() async {
    try {
      final user = await authRepository.registerWithApple();
      return Right(user); // ✅ Success
    } catch (e) {
      return Left(ServerFailure('Failed to register with Apple: ${e.toString()}')); //  Error
    }
  }
}
