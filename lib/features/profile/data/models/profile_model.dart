import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.email,
    required super.username,
    super.profilePictureUrl,
    required super.isEmailVerified,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      profilePictureUrl: json['profilePictureUrl'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  factory ProfileModel.fromStrapiJson(Map<String, dynamic> json) {
    // Handle Strapi v4 format with attributes
    final attributes = json['attributes'] ?? json;
    
    return ProfileModel(
      id: json['id']?.toString() ?? attributes['id']?.toString() ?? '',
      email: attributes['email'] ?? '',
      username: attributes['username'] ?? '',
      profilePictureUrl: _extractProfilePictureUrl(attributes['profilePicture']),
      isEmailVerified: attributes['isEmailVerified'] ?? false,
      createdAt: _parseDateTime(attributes['createdAt']),
      updatedAt: _parseDateTime(attributes['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static String? _extractProfilePictureUrl(dynamic profilePicture) {
    if (profilePicture == null) return null;
    
    // Handle different Strapi response formats
    if (profilePicture is String) {
      return profilePicture;
    }
    
    if (profilePicture is Map<String, dynamic>) {
      // Check for direct URL
      if (profilePicture['url'] != null) {
        return profilePicture['url'];
      }
      
      // Check for Strapi media format
      final data = profilePicture['data'];
      if (data is Map<String, dynamic>) {
        final attributes = data['attributes'];
        if (attributes is Map<String, dynamic>) {
          return attributes['url'];
        }
      }
      
      // Check for array format
      if (data is List && data.isNotEmpty) {
        final firstItem = data.first;
        if (firstItem is Map<String, dynamic>) {
          final attributes = firstItem['attributes'];
          if (attributes is Map<String, dynamic>) {
            return attributes['url'];
          }
        }
      }
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toStrapiUpdateJson() {
    final Map<String, dynamic> data = {};
    
    if (username.isNotEmpty) {
      data['username'] = username;
    }
    
    if (profilePictureUrl != null) {
      data['profilePictureUrl'] = profilePictureUrl;
    }
    
    return data;
  }

  ProfileModel copyWith({
    String? id,
    String? email,
    String? username,
    String? profilePictureUrl,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}