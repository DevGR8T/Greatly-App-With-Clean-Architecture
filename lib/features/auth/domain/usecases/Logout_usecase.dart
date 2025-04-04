import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;

  LogoutUseCase(this.authRepository);

  Future<Either<Failure, void>> call() async {
    try {
      await authRepository.signOut();
      return const Right(null); // Success
    } catch (e) {
      return Left(ServerFailure('Failed to logout: ${e.toString()}')); //  Error
    }
  }
}
