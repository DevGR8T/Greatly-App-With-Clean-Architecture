import 'package:dartz/dartz.dart';
import '../entities/review.dart';
import '../../../../core/error/failure.dart';

abstract class ReviewRepository {
  /// Get all reviews for a specific product
  Future<Either<Failure, List<Review>>> getProductReviews(String productId);

  /// Get average rating for a specific product
  Future<Either<Failure, double>> getProductAverageRating(String productId);
  
  /// Submit a new review for a product
  Future<Either<Failure, Review>> submitReview({
    required String productId,
    required double rating,
    required String comment,
  });
  
  /// Check if current user has already reviewed the product
  Future<Either<Failure, bool>> hasUserReviewedProduct(String productId);
  
}
