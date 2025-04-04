import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  final AuthRepository authRepository;

  RegisterWithEmailUseCase(this.authRepository);

  Future<Either<Failure, User>> call(
    String email, 
    String password, 
    {String? username, String? phone}
  ) async {
    try {
      final user = await authRepository.registerWithEmail(
        email,
        password,
        username: username,
        phone: phone,
      );
      return Right(user); // Success
    } catch (e) {
      return Left(ServerFailure('Failed to register with email: ${e.toString()}')); //  Error
    }
  }
}
