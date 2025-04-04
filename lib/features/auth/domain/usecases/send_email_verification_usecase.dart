import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerificationUseCase {
  final AuthRepository authRepository;

  SendEmailVerificationUseCase(this.authRepository);

  Future<Either<Failure, void>> call() async {
    try {
      await authRepository.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to send email verification: ${e.toString()}'));
    }
  }
}