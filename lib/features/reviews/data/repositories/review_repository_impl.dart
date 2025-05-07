// lib/features/reviews/data/repositories/review_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/remote/review_remote_data_source.dart';

@LazySingleton(as: ReviewRepository)
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Review>>> getProductReviews(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteReviews = await remoteDataSource.getProductReviews(productId);
        return Right(remoteReviews);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, double>> getProductAverageRating(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final averageRating = await remoteDataSource.getProductAverageRating(productId);
        return Right(averageRating);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }

 @override
Future<Either<Failure, Review>> submitReview({
  required String productId,
  required double rating,
  required String comment,
}) async {
  if (await networkInfo.isConnected) {
    try {
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left(AuthFailure('You must be logged in to submit a review'));
      }
      
      final reviewResponse = await remoteDataSource.submitReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      return Right(reviewResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  } else {
    return const Left(ConnectionFailure('No internet connection'));
  }
}

  @override
  Future<Either<Failure, bool>> hasUserReviewedProduct(String productId) async {
    if (await networkInfo.isConnected) {
      try {
        final hasReviewed = await remoteDataSource.hasUserReviewedProduct(productId);
        return Right(hasReviewed);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }
}