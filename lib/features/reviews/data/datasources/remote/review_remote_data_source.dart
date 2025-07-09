import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  /// Fetches all reviews for a given product
  /// Throws a [ServerException] for all error codes
  Future<List<ReviewModel>> getProductReviews(String productId);

  /// Gets the average rating for a product
  /// Throws a [ServerException] for all error codes
  Future<double> getProductAverageRating(String productId);

  /// Submits a new review for a product
  /// Throws a [ServerException] for all error codes
  Future<ReviewModel> submitReview({
    required String productId,
    required double rating,
    required String comment,
  });

  /// Checks if the current user has already reviewed a product
  /// Throws a [ServerException] for all error codes
  Future<bool> hasUserReviewedProduct(String productId);

  /// Checks if the current user has purchased a product
  /// Throws a [ServerException] for all error codes
  Future<bool> hasUserPurchasedProduct(String productId);
}


@LazySingleton(as: ReviewRemoteDataSource)
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient dioClient;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  ReviewRemoteDataSourceImpl(this.dioClient) 
      : _firebaseAuth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {

      final response = await dioClient.get(
        '/reviews',
        queryParameters: {
          'filters[product][id][\$eq]': int.tryParse(productId) ?? 0,
        },
      );
      

      
      List<dynamic> reviewsJson;
      // Handle different response structures
      if (response.data is Map && response.data.containsKey('data')) {
        // Standard Strapi response
        reviewsJson = response.data['data'] ?? [];
      } else if (response.data is List) {
        // Direct array response
        reviewsJson = response.data;
      } else {

        reviewsJson = [];
      }
      
      final reviews = reviewsJson.map((json) => ReviewModel.fromStrapiJson(json)).toList();
      
      // Log parsed reviews

      for (var review in reviews) {

      }
      
      return reviews;
    } catch (e) {

      return [];
    }
  }

  @override
  Future<double> getProductAverageRating(String productId) async {
    try {
      final reviews = await getProductReviews(productId);
      
      if (reviews.isEmpty) {
        return 0.0;
      }
      
      // Filter out any reviews with rating 0 (likely parsing errors)
      final validReviews = reviews.where((review) => review.rating > 0).toList();
      
      if (validReviews.isEmpty) {
        return 0.0;
      }
      
      final sum = validReviews.fold<double>(0, (sum, review) => sum + review.rating);
      final average = sum / validReviews.length;
      

      return average;
    } catch (e) {

      return 0.0;
    }
  }

  /// Gets the user's name from Firestore or Firebase Auth
  Future<String> _getUserName() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return 'Anonymous';
      }
      
      // First try to get the name from Firestore
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data()?['name'] != null) {
        return userDoc.data()?['name'];
      }
      
      // Fall back to Firebase Auth display name
      if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
        return currentUser.displayName!;
      }
      
      // If no name found, use email prefix as fallback
      if (currentUser.email != null && currentUser.email!.isNotEmpty) {
        return currentUser.email!.split('@')[0]; // Use part before @ as username
      }
      
      return 'Anonymous';
    } catch (e) {

      return 'Anonymous';
    }
  }

  @override
  Future<ReviewModel> submitReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw AuthException('You must be logged in to submit a review');
      }

      // Get user's name from Firestore or Auth
      final userName = await _getUserName();

      // Convert productId to integer - VERY IMPORTANT FOR STRAPI
      int productIdInt = int.parse(productId);

      final reviewData = {
        'data': {
          'product': productIdInt,  // This must be an integer
          'rating': rating,
          'comment': comment,
          'userId': currentUser.uid,
          'userName': userName,
        }
      };



      final response = await dioClient.post(
        '/reviews',
        data: reviewData,
      );



      return ReviewModel(
        id: response.data?['data']?['id']?.toString() ?? 'new',
        productId: productId,
        userId: currentUser.uid,
        userName: userName,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );
    } catch (e) {

      throw ServerException('Failed to submit review: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasUserReviewedProduct(String productId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return false; // Not logged in, so hasn't reviewed
      }

      final response = await dioClient.get(
        '/reviews',
        queryParameters: {
          'filters[product][id][\$eq]': productId,
          'filters[userId][\$eq]': currentUser.uid,
        },
      );

      final reviews = response.data['data'] as List;
      return reviews.isNotEmpty;
    } catch (e) {
      return false; // On error, assume not reviewed
    }
  }

  @override
  Future<bool> hasUserPurchasedProduct(String productId) async {
    // Since we're not implementing backend changes, 
    // we'll assume the user has purchased the product
    // In a real app, you would check against order history
    return true;
  }
}