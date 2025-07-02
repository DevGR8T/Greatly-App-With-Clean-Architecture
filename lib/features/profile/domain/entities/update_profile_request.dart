import 'package:equatable/equatable.dart';

class UpdateProfileRequest extends Equatable {
  final String? username;
  final String? profilePictureUrl;

  const UpdateProfileRequest({
    this.username,
    this.profilePictureUrl,
  });

  bool get hasChanges => username != null || profilePictureUrl != null;

  @override
  List<Object?> get props => [username, profilePictureUrl];
}