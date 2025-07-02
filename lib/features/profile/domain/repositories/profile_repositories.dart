import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile.dart';
import '../entities/update_profile_request.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, Profile>> updateProfile(UpdateProfileRequest request);
  Future<Either<Failure, String>> uploadProfilePicture(File imageFile);
  Future<Either<Failure, void>> deleteProfilePicture();
  Future<Either<Failure, void>> logout();
}