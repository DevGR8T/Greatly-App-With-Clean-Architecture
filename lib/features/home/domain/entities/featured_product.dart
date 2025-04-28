import 'package:equatable/equatable.dart';

/// Represents a featured product in the application.
class FeaturedProduct extends Equatable {
  final int id; // Unique identifier of the product.
  final String name; // Name of the product.
  final String description; // Brief description of the product.
  final double price; // Price of the product.
  final String imageUrl; // URL of the product's image.
  final int stock; // Stock quantity of the product.
  final String category; // Category of the product.

  /// Creates a new [FeaturedProduct] instance.
  const FeaturedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
  });

  /// Properties used for equality comparison.
  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        stock,
        category,
      ];
}