import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/config/env/env_config.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';

import '../../models/profile_model.dart';
import '../../models/update_profile_request_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(UpdateProfileRequestModel request);
  Future<String> uploadProfilePicture(File imageFile);
  Future<void> deleteProfilePicture();
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;
  final FirebaseAuth firebaseAuth;
  final EnvConfig envConfig;

  ProfileRemoteDataSourceImpl({
    required this.dioClient,
    required this.firebaseAuth,
    required this.envConfig,
  });

@override
Future<ProfileModel> getProfile() async {
  try {
    final user = firebaseAuth.currentUser;
    
    // Try to get profile from Strapi first
    try {
      final response = await dioClient.get('/users/me?populate=profilePicture');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Combine Firebase user data with Strapi profile data
        final profileData = {
          'id': data['id']?.toString() ?? user?.uid ?? '',
          'email': user?.email ?? data['email'] ?? '',
          'username': data['username'] ?? user?.displayName ?? _extractUsernameFromEmail(user?.email),
          'profilePicture': data['profilePicture'],
          'isEmailVerified': user?.emailVerified ?? false,
          'createdAt': data['createdAt'] ?? user?.metadata.creationTime?.toIso8601String(),
          'updatedAt': data['updatedAt'] ?? DateTime.now().toIso8601String(),
        };
        
        return ProfileModel.fromStrapiJson(profileData);
      }
    } catch (e) {
      // If Strapi fails, create profile from Firebase data only

    }
    
    // Fallback to Firebase data only (handle null user case)
    final profileData = {
      'id': user?.uid ?? '',
      'email': user?.email ?? '',
      'username': user?.displayName ?? _extractUsernameFromEmail(user?.email),
      'profilePictureUrl': user?.photoURL,
      'isEmailVerified': user?.emailVerified ?? false,
      'createdAt': user?.metadata.creationTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    return ProfileModel.fromJson(profileData);
    
  } on DioException catch (e) {
    throw _handleDioException(e);
  } catch (e) {
    throw ServerException('Unexpected error occurred: $e');
  }
}

  String _extractUsernameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'User';
    return email.split('@').first;
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileRequestModel request) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw  AuthException('User not authenticated');
      }

      final updateData = request.toJson();
      if (updateData.isEmpty) {
        throw  ServerException('No data to update');
      }

      // Update in Strapi
      try {
        final response = await dioClient.put(
          '/users/${user.uid}',
          data: updateData,
        );

        if (response.statusCode != 200) {
          throw ServerException('Failed to update profile in Strapi: ${response.statusMessage}');
        }
      } catch (e) {

        // Continue with Firebase update even if Strapi fails
      }

      // Update Firebase display name if username changed
      if (request.username != null && request.username != user.displayName) {
        try {
          await user.updateDisplayName(request.username);
          await user.reload();
        } catch (e) {

        }
      }

      // Update Firebase photo URL if profile picture changed
      if (request.profilePictureUrl != null && request.profilePictureUrl != user.photoURL) {
        try {
          await user.updatePhotoURL(request.profilePictureUrl);
          await user.reload();
        } catch (e) {

        }
      }

      // Return updated profile
      return await getProfile();
      
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AuthException || e is ServerException) rethrow;
      throw ServerException('Unexpected error occurred: $e');
    }
  }

@override
Future<String> uploadProfilePicture(File imageFile) async {
  try {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw AuthException('User not authenticated');
    }
    
    final fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
    
    final formData = FormData.fromMap({
      'files': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });
    
    final uploadResponse = await dioClient.post(
      '/upload',
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    


    
    if (uploadResponse.statusCode == 201 || uploadResponse.statusCode == 200) {
      final responseData = uploadResponse.data;
      String? imageUrl;
      
      if (responseData is List && responseData.isNotEmpty) {
        final fileData = responseData.first as Map<String, dynamic>;
        
        // The URL is in the 'url' field
        imageUrl = fileData['url'] as String?;
        

        
        if (imageUrl == null) {
          throw ServerException('No image URL returned from upload');
        }
        
        // Make sure URL is absolute
        if (!imageUrl.startsWith('http')) {
          imageUrl = '${envConfig.baseUrl}$imageUrl';
        }
        

        
        return imageUrl;
      } else {
        throw ServerException('Invalid response format from upload');
      }
    } else {
      throw ServerException('Failed to upload image: ${uploadResponse.statusMessage}');
    }
  } on DioException catch (e) {


    throw ServerException('Dio error: ${e.message}');
  } on AuthException catch (e) {

    rethrow;
  } on ServerException catch (e) {

    rethrow;
  } catch (e) {


    throw ServerException('Unexpected error occurred: ${e.toString()}');
  }
}

  @override
  Future<void> deleteProfilePicture() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw  AuthException('User not authenticated');
      }

      // Remove profile picture from Strapi
      try {
        await dioClient.put(
          '/users/${user.uid}',
          data: {'profilePictureUrl': null},
        );
      } catch (e) {

      }

      // Remove profile picture from Firebase
      try {
        await user.updatePhotoURL(null);
        await user.reload();
      } catch (e) {

      }
      
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException('Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Failed to logout: $e');
    }
  }

  ServerException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return  ServerException('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? e.response?.statusMessage;
        switch (statusCode) {
          case 400:
            return ServerException('Bad request: ${message ?? 'Invalid data'}');
          case 401:
            return  ServerException('Unauthorized access');
          case 403:
            return  ServerException('Access forbidden');
          case 404:
            return  ServerException('Profile not found');
          case 422:
            return ServerException('Validation error: ${message ?? 'Invalid input'}');
          case 500:
            return  ServerException('Internal server error');
          default:
            return ServerException('Server error ($statusCode): ${message ?? 'Unknown error'}');
        }
      case DioExceptionType.cancel:
        return  ServerException('Request cancelled');
      case DioExceptionType.connectionError:
        return  ServerException('No internet connection');
      default:
        return ServerException('Network error: ${e.message}');
    }
  }
}