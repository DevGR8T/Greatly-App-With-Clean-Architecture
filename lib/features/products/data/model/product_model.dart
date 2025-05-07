import '../../domain/entities/product.dart';
import 'category_model.dart';

class ProductModel extends Product {
  ProductModel({
    required String id,
    required String name,
    required String description,
    required double price,
    required double originalPrice,
    int discount = 0,
    required String imageUrl,
    required List<String> images,
    required CategoryModel category,
    double rating = 0.0,
    int reviewCount = 0,
    bool isNew = false,
    int stockQuantity = 0,
    Map<String, String> specifications = const {},
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          description: description,
          price: price,
          originalPrice: originalPrice,
          discount: discount,
          imageUrl: imageUrl,
          images: images,
          category: category,
          rating: rating,
          reviewCount: reviewCount,
          isNew: isNew,
          stockQuantity: stockQuantity,
          specifications: specifications,
          createdAt: createdAt,
        );

  // Helper method to safely parse rating values
  static double parseRating(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

factory ProductModel.fromJson(Map<String, dynamic> json) {
  print('Complete product JSON: $json'); // Keep this for debugging
  
  // Extract ID with proper handling of Strapi's data structure
  String id = '';
  try {
    // First check if we have a direct ID
    if (json['id'] != null) {
      id = json['id'].toString();
      print('Found direct ID: $id');
    } 
    // If ID is nested in a data object
    else if (json['data'] != null && json['data']['id'] != null) {
      id = json['data']['id'].toString();
      print('Found ID in data object: $id');
    }
    
    print('Final extracted product ID: $id');
  } catch (e) {
    print('Error extracting product ID: $e');
  }
  
  // Extract main image URL with improved handling
  String imageUrl = '';
  try {
    // For Strapi v4 structure
    if (json['attributes'] != null && json['attributes']['image'] != null) {
      var imageData = json['attributes']['image']['data'];
      if (imageData != null && imageData['attributes'] != null) {
        imageUrl = imageData['attributes']['url'] ?? '';
      }
    }
    // Direct image object
    else if (json['image'] != null) {
      // Try to get URL from formats -> small
      if (json['image']['formats'] != null && 
          json['image']['formats']['small'] != null) {
        imageUrl = json['image']['formats']['small']['url'] ?? '';
      } 
      // Try direct URL
      else if (json['image']['url'] != null) {
        imageUrl = json['image']['url'];
      }
      // Try data -> attributes path
      else if (json['image']['data'] != null && 
              json['image']['data']['attributes'] != null) {
        imageUrl = json['image']['data']['attributes']['url'] ?? '';
      }
    }
    // If still empty, check for a direct imageUrl field
    if (imageUrl.isEmpty && json['imageUrl'] != null) {
      imageUrl = json['imageUrl'];
    }
    
    print('Extracted main image path: $imageUrl');
  } catch (e) {
    print('Error parsing product image: $e');
  }
  
  // Extract multiple images
  List<String> images = [];
  try {
    // First add the main image if it exists
    if (imageUrl.isNotEmpty) {
      images.add(imageUrl);
    }
    
    // Print the structure of images field for debugging
    if (json['images'] != null) {
      print('Images field structure: ${json['images']}');
      
      // Handle different possible structures
      if (json['images'] is List) {
        // Direct list of image strings or objects
        List imagesList = json['images'] as List;
        for (var img in imagesList) {
          if (img is String) {
            images.add(img);
          } else if (img is Map && img['url'] != null) {
            images.add(img['url'].toString());
          }
        }
      } 
      // Handle Strapi v4 structure
      else if (json['images'] is Map) {
        if (json['images']['data'] != null) {
          var imagesData = json['images']['data'];
          if (imagesData is List) {
            for (var imgData in imagesData) {
              if (imgData is Map && 
                  imgData['attributes'] != null && 
                  imgData['attributes']['url'] != null) {
                final url = imgData['attributes']['url'].toString();
                if (url.isNotEmpty && !images.contains(url)) {
                  images.add(url);
                }
              }
            }
          }
        }
      }
    }
    
    // Check for images in attributes (alternative Strapi structure)
    if (json['attributes'] != null && json['attributes']['images'] != null) {
      print('Attributes images field structure: ${json['attributes']['images']}');
      
      var attrImages = json['attributes']['images'];
      if (attrImages is List) {
        for (var img in attrImages) {
          if (img is String) {
            images.add(img);
          } else if (img is Map && img['url'] != null) {
            images.add(img['url'].toString());
          }
        }
      } else if (attrImages is Map && attrImages['data'] != null) {
        var imagesData = attrImages['data'];
        if (imagesData is List) {
          for (var imgData in imagesData) {
            if (imgData is Map && 
                imgData['attributes'] != null && 
                imgData['attributes']['url'] != null) {
              final url = imgData['attributes']['url'].toString();
              if (url.isNotEmpty && !images.contains(url)) {
                images.add(url);
              }
            }
          }
        }
      }
    }
    
    print('Successfully parsed images: $images');
  } catch (e) {
    print('Error parsing multiple images: $e');
    // If we failed to parse multiple images, at least use the main image
    if (imageUrl.isNotEmpty && images.isEmpty) {
      images = [imageUrl];
    }
  }
  
  // Create category model
  CategoryModel category;
  try {
    // Strapi v4 path
    if (json['category'] != null && json['category']['data'] != null) {
      var categoryData = json['category']['data'];
      var catId = categoryData['id']?.toString() ?? '0';
      var catName = categoryData['attributes']?['name']?.toString() ?? 'Unknown';
      category = CategoryModel(id: catId, name: catName);
    }
    // Direct category object 
    else if (json['category'] != null) {
      category = CategoryModel.fromJson(json['category']);
    } 
    else {
      category = CategoryModel(id: '0', name: 'Uncategorized');
    }
  } catch (e) {
    print('Error parsing category: $e');
    category = CategoryModel(id: '0', name: 'Uncategorized');
  }
  
  // Parse dates safely
  DateTime createdAt;
  try {
    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now();
  } catch (e) {
    try {
      // Try alternate date format/field
      createdAt = json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now();
    } catch (e2) {
      print('Error parsing date: $e2');
      createdAt = DateTime.now();
    }
  }
  
  // Handle null values and type conversions safely
  double price = 0.0;
  if (json['price'] != null) {
    price = (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0;
  }
  
  double originalPrice = price;
  if (json['originalPrice'] != null) {
    originalPrice = (json['originalPrice'] is num) ? (json['originalPrice'] as num).toDouble() : price;
  }
  
  // Parse rating more safely
  double rating = 0.0;
  try {
    // First check for direct rating in json
    if (json['rating'] != null) {
      rating = parseRating(json['rating']);
    }
    // Then check rating in attributes for Strapi structure
    else if (json['attributes'] != null && json['attributes']['rating'] != null) {
      rating = parseRating(json['attributes']['rating']);
    }
    
    // Debug output for rating
    print('Extracted rating for product: ${json['name'] ?? 'Unknown'} = $rating');
  } catch (e) {
    print('Error parsing rating: $e');
    rating = 0.0;
  }
  
  return ProductModel(
    id: id.isEmpty ? json['id']?.toString() ?? '' : id,
    name: json['name']?.toString() ?? 'Unknown Product',
    description: json['description']?.toString() ?? '',
    price: price,
    originalPrice: originalPrice,
    discount: json['discount'] is num ? json['discount'] : 0,
    imageUrl: imageUrl,
    images: images.isNotEmpty ? images : [imageUrl],  // Use the images list, fallback to single image
    category: category,
    rating: rating, // Use the safely parsed rating
    reviewCount: json['reviewCount'] is num ? json['reviewCount'] : 0,
    isNew: json['isNew'] == true,
    stockQuantity: json['stock'] is num ? json['stock'] : 0,
    specifications: Map<String, String>.from(json['specifications'] ?? {}),
    createdAt: createdAt,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'discount': discount,
      'imageUrl': imageUrl,
      'images': images,
      'category': (category as CategoryModel).toJson(),
      'rating': rating,
      'reviewCount': reviewCount,
      'isNew': isNew,
      'stockQuantity': stockQuantity,
      'specifications': specifications,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}