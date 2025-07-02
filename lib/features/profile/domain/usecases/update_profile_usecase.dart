import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

import '../entities/profile.dart';
import '../entities/update_profile_request.dart';
import '../repositories/profile_repositories.dart';

class UpdateProfileUsecase implements UseCase<Profile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUsecase(this.repository);

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParams params) async {
    // Validate username if provided
    if (params.request.username != null) {
      final usernameValidation = _validateUsername(params.request.username!);
      if (usernameValidation != null) {
        return Left(ValidationFailure(usernameValidation));
      }
    }

    return await repository.updateProfile(params.request);
  }

  String? _validateUsername(String username) {
    if (username.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    if (username.trim().length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (username.trim().length > 30) {
      return 'Username cannot exceed 30 characters';
    }
    // Only allow alphanumeric characters, underscores, and periods
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username.trim())) {
      return 'Username can only contain letters, numbers, periods, and underscores';
    }
    return null;
  }
}

class UpdateProfileParams {
  final UpdateProfileRequest request;

  UpdateProfileParams({required this.request});
}