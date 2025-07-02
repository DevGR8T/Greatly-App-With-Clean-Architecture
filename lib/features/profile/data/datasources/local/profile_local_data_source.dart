import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/error/exceptions.dart';
import '../../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel> getCachedProfile();
  Future<void> cacheProfile(ProfileModel profile);
  Future<void> clearCachedProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedProfileKey = 'CACHED_PROFILE';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ProfileModel> getCachedProfile() async {
    try {
      final jsonString = sharedPreferences.getString(cachedProfileKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return ProfileModel.fromJson(jsonMap);
      } else {
        throw  CacheException('No cached profile found');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to get cached profile: $e');
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    try {
      final jsonString = json.encode(profile.toJson());
      final success = await sharedPreferences.setString(cachedProfileKey, jsonString);
      if (!success) {
        throw  CacheException('Failed to save profile to cache');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to cache profile: $e');
    }
  }

  @override
  Future<void> clearCachedProfile() async {
    try {
      final success = await sharedPreferences.remove(cachedProfileKey);
      if (!success) {
        throw  CacheException('Failed to clear cached profile');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to clear cached profile: $e');
    }
  }
}