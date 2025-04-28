import 'category.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final int discount;
  final String imageUrl;
  final List<String> images;
  final Category category;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final int stockQuantity;
  final Map<String, String> specifications;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    this.discount = 0,
    required this.imageUrl,
    required this.images,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isNew = false,
    this.stockQuantity = 0,
    this.specifications = const {},
    required this.createdAt,
  });
}