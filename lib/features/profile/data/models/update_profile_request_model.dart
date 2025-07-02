import '../../domain/entities/update_profile_request.dart';

class UpdateProfileRequestModel extends UpdateProfileRequest {
  const UpdateProfileRequestModel({
    super.username,
    super.profilePictureUrl,
  });

  factory UpdateProfileRequestModel.fromDomain(UpdateProfileRequest request) {
    return UpdateProfileRequestModel(
      username: request.username,
      profilePictureUrl: request.profilePictureUrl,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (username != null && username!.trim().isNotEmpty) {
      data['username'] = username!.trim();
    }
    
    if (profilePictureUrl != null) {
      data['profilePictureUrl'] = profilePictureUrl;
    }
    
    return data;
  }
}