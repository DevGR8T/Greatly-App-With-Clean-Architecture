import '../../domain/entities/featured_product.dart';

/// Model for featured products, extending the [FeaturedProduct] entity.
class FeaturedProductModel extends FeaturedProduct {
  /// Creates a [FeaturedProductModel] instance.
  const FeaturedProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.stock,
    required super.category,
  });

  /// Parses a JSON object into a [FeaturedProductModel].
  factory FeaturedProductModel.fromJson(Map<String, dynamic> json) {
    print('Parsing product JSON: $json'); // Debugging JSON parsing

    // Extract image URL, handling nested structures and fallbacks.
    String imageUrl = '';
    try {
      if (json['image'] != null &&
          json['image']['formats'] != null &&
          json['image']['formats']['small'] != null) {
        imageUrl = json['image']['formats']['small']['url'] ?? '';
      } else if (json['image'] != null && json['image']['url'] != null) {
        imageUrl = json['image']['url'];
      }
    } catch (e) {

    }
    print('Parsed imageUrl: $imageUrl'); // Debug parsed image URL

    // Extract category name, handling nested structures.
    String category = '';
    try {
      if (json['category'] != null &&
          json['category']['data'] != null &&
          json['category']['data']['attributes'] != null) {
        category = json['category']['data']['attributes']['name'] ?? '';
      }
    } catch (e) {

    }

    // Return the parsed model.
    return FeaturedProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      imageUrl: imageUrl,
      stock: json['stock'] ?? 0,
      category: category,
    );
  }
}