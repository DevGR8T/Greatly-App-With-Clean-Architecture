import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository authRepository;

  SendPasswordResetEmailUseCase(this.authRepository);

  Future<Either<Failure, void>> call(String email) async {
    try {
      await authRepository.sendPasswordResetEmail(email);
      return const Right(null); // Success 
    } catch (e) {
      return Left(ServerFailure( e.toString())); //  Error
    }
  }
}
