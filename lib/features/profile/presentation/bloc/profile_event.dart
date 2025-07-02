import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/update_profile_request.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final UpdateProfileRequest request;

  const UpdateProfile(this.request);

  @override
  List<Object> get props => [request];
}

class UploadProfilePicture extends ProfileEvent {
  final File imageFile;

  const UploadProfilePicture(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class DeleteProfilePicture extends ProfileEvent {}

class LogoutUser extends ProfileEvent {}
