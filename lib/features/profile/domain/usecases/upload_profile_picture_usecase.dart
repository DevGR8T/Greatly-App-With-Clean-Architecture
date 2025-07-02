import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repositories.dart';


class UploadProfilePictureUsecase implements UseCase<String, UploadProfilePictureParams> {
  final ProfileRepository repository;

  UploadProfilePictureUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(UploadProfilePictureParams params) async {
    // Validate image file
    final validation = _validateImageFile(params.imageFile);
    if (validation != null) {
      return Left(ValidationFailure(validation));
    }

    return await repository.uploadProfilePicture(params.imageFile);
  }

  String? _validateImageFile(File imageFile) {
    // Check if file exists
    if (!imageFile.existsSync()) {
      return 'Image file does not exist';
    }

    // Check file size (max 5MB)
    final fileSizeInBytes = imageFile.lengthSync();
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    if (fileSizeInBytes > maxSizeInBytes) {
      return 'Image file size cannot exceed 5MB';
    }

    // Check file extension
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final fileExtension = imageFile.path.toLowerCase().split('.').last;
    if (!allowedExtensions.contains('.$fileExtension')) {
      return 'Only JPG, JPEG, PNG, and WebP images are allowed';
    }

    return null;
  }
}

class UploadProfilePictureParams {
  final File imageFile;

  UploadProfilePictureParams({required this.imageFile});
}