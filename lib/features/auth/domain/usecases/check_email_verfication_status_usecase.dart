import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class CheckEmailVerificationStatusUseCase {
  final AuthRepository authRepository;

  CheckEmailVerificationStatusUseCase(this.authRepository);

  Future<Either<Failure, bool>> call() async {
    try {
      final isVerified = await authRepository.isEmailVerified();
      return Right(isVerified);
    } catch (e) {
      return Left(ServerFailure('Failed to check email verification status: ${e.toString()}'));
    }
  }
}