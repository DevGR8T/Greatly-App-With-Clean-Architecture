import 'package:greatly_user/core/utils/json_helper.dart';

import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required String id,
    required String name,
    String? imageUrl,
    String? description,
    int? productCount,
  }) : super(
          id: id,
          name: name,
          imageUrl: imageUrl,
          description: description,
          productCount: productCount,
        );

  /// Parses a JSON object into a [CategoryModel].
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
  if (json.isEmpty) {
    // Provide a default "Uncategorized" category if the JSON is empty
    return CategoryModel(
      id: '',
      name: 'Uncategorized',
      imageUrl: null,
      description: null,
      productCount: null,
    );
  }

  // Extract the category ID, which might be in different formats
  String id = '';
  if (json['id'] != null) {
    id = json['id'].toString();
  } else if (json['_id'] != null) {
    id = json['_id'].toString();
  }

  // Extract image URL from nested JSON structure with better fallback handling
  String? imageUrl;
  if (json['image'] != null) {
    if (json['image'] is Map) {
      // Try to get small format first, then fall back to full URL
      imageUrl = JsonHelper.getNestedValue(
        json,
        ['image', 'formats', 'small', 'url'],
      ) ?? JsonHelper.getNestedValue(json, ['image', 'url']);
    } else if (json['image'] is String) {
      // Handle case where image might be a direct URL string
      imageUrl = json['image'] as String;
    }
  }

  // Handle category data
  return CategoryModel(
    id: id,
    name: json['name'] ?? 'Unknown Category',
    imageUrl: imageUrl,
    description: json['description'] ?? '',
    productCount: json['productCount'] != null
        ? int.tryParse(json['productCount'].toString())
        : null,
  );
}

  /// Converts a [CategoryModel] into a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'productCount': productCount,
    };
  }
}