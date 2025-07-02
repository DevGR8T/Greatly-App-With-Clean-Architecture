
// lib/profile/data/repositories/profile_repository_impl.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';

import '../../domain/entities/profile.dart';
import '../../domain/entities/update_profile_request.dart';
import '../../domain/repositories/profile_repositories.dart';

import '../datasources/local/profile_local_data_source.dart';

import '../datasources/remote/profile_remote_datasources.dart';

import '../models/update_profile_request_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProfile = await remoteDataSource.getProfile();
        // Cache the profile for offline use
        try {
          await localDataSource.cacheProfile(remoteProfile);
        } catch (e) {
          // Don't fail if caching fails
          print('Failed to cache profile: $e');
        }
        return Right(remoteProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure('Unexpected error: $e'));
      }
    } else {
      // Try to get cached profile when offline
      try {
        final cachedProfile = await localDataSource.getCachedProfile();
        return Right(cachedProfile);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(UpdateProfileRequest request) async {
    if (await networkInfo.isConnected) {
      try {
        final requestModel = UpdateProfileRequestModel.fromDomain(request);
        final updatedProfile = await remoteDataSource.updateProfile(requestModel);
        
        // Update cache with new profile
        try {
          await localDataSource.cacheProfile(updatedProfile);
        } catch (e) {
          // Don't fail if caching fails
          print('Failed to cache updated profile: $e');
        }
        
        return Right(updatedProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure('Unexpected error: $e'));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection available'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(File imageFile) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await remoteDataSource.uploadProfilePicture(imageFile);
        return Right(imageUrl);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure('Unexpected error: $e'));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection available'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfilePicture() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProfilePicture();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(GeneralFailure('Unexpected error: $e'));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection available'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      
      // Clear cached profile data
      try {
        await localDataSource.clearCachedProfile();
      } catch (e) {
        // Don't fail logout if cache clearing fails
        print('Failed to clear cached profile during logout: $e');
      }
      
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }
}