// lib/features/reviews/data/models/review_model.dart
import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  ReviewModel({
    required String id,
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    required DateTime createdAt,
  }) : super(
          id: id,
          productId: productId,
          userId: userId,
          userName: userName,
          rating: rating,
          comment: comment,
          createdAt: createdAt,
        );

  factory ReviewModel.fromStrapiJson(Map<String, dynamic> json) {
    // Print the raw JSON for debugging
    print('Review JSON from Strapi: $json');
    
    // First check if the response has attributes in the Strapi format
    // If not, use the root object directly
    final Map<String, dynamic> data = json['attributes'] != null ? 
      json['attributes'] : json;
    
    // Extract user info
    String userName = data['userName'] ?? 'Anonymous';
    String userId = data['userId'] ?? '';
    
    // Parse rating (ensuring it's a double)
    double rating = 0.0;
    if (data['rating'] != null) {
      if (data['rating'] is int) {
        rating = data['rating'].toDouble();
      } else if (data['rating'] is double) {
        rating = data['rating'];
      } else if (data['rating'] is String) {
        rating = double.tryParse(data['rating']) ?? 0.0;
      }
    }
    
    // Get comment
    String comment = data['comment'] ?? '';
    
    // Parse date
    DateTime createdAt;
    try {
      createdAt = data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now();
    } catch (e) {
      createdAt = DateTime.now();
      print('Error parsing date: $e');
    }
    
    // Get product ID
    String productId = '';
    if (data['product'] != null) {
      if (data['product'] is Map) {
        productId = data['product']['id']?.toString() ?? '';
      } else {
        productId = data['product'].toString();
      }
    }
    
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      productId: productId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }
}