import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repositories.dart';


class DeleteProfilePictureUsecase implements UseCase<void, NoParams> {
  final ProfileRepository repository;

  DeleteProfilePictureUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteProfilePicture();
  }
}