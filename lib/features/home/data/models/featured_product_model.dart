import '../../domain/entities/featured_product.dart';

class FeaturedProductModel extends FeaturedProduct {
  const FeaturedProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.stock,
    required super.category,
  });

 factory FeaturedProductModel.fromJson(Map<String, dynamic> json) {
  // Debug prints
  print('Parsing product JSON: $json');

  String imageUrl = '';
  try {
    if (json['image'] != null &&
        json['image']['formats'] != null &&
        json['image']['formats']['small'] != null) {
      imageUrl = json['image']['formats']['small']['url'] ?? '';
    } else if (json['image'] != null && json['image']['url'] != null) {
      // Fallback to the default image URL if 'formats' is missing
      imageUrl = json['image']['url'];
    }
  } catch (e) {
    print('Error parsing product image: $e');
  }

  print('Parsed imageUrl: $imageUrl'); // Debug the parsed image URL

  String category = '';
  try {
    if (json['category'] != null &&
        json['category']['data'] != null &&
        json['category']['data']['attributes'] != null) {
      category = json['category']['data']['attributes']['name'] ?? '';
    }
  } catch (e) {
    print('Error parsing product category: $e');
  }

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