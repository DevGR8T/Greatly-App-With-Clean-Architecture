import 'package:dio/dio.dart';
import 'package:greatly_user/core/network/dio_client.dart';
import 'package:greatly_user/features/products/data/model/category_model.dart';
import 'package:greatly_user/features/products/data/model/product_model.dart';
import 'package:greatly_user/features/reviews/data/datasources/remote/review_remote_data_source.dart';

import '../../../../../core/error/exceptions.dart';

abstract class ProductRemoteDataSource {
  Future<Map<String, dynamic>> getProducts({
    String? query,
    String? categoryId,
    String? sortOption,
    int page = 1,
  });

  Future<ProductModel> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient client;
  final ReviewRemoteDataSource reviewRemoteDataSource;

  ProductRemoteDataSourceImpl(this.client, this.reviewRemoteDataSource);

  @override
  Future<Map<String, dynamic>> getProducts({
    String? query,
    String? categoryId,
    String? sortOption,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'pagination[page]': page,
        'pagination[pageSize]': 100,
        'populate': '*',
      };

      if (query != null && query.isNotEmpty) {
        queryParams['filters[\$or][0][name][\$containsi]'] = query;
        queryParams['filters[\$or][1][description][\$containsi]'] = query;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['filters[category][id]'] = categoryId;
      }

      if (sortOption != null) {
        queryParams['sort'] = _mapSortOption(sortOption);
      }

      final response = await client.get('/products', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final productsJsonList = response.data['data'] as List<dynamic>;

        final List<ProductModel> products = [];
        for (var json in productsJsonList) {
          final product = ProductModel.fromJson(json);

          // Fetch reviews for this product
          final reviews = await reviewRemoteDataSource.getProductReviews(product.id);
          double averageRating = 0.0;
          if (reviews.isNotEmpty) {
            final validReviews = reviews.where((review) => review.rating > 0).toList();
            if (validReviews.isNotEmpty) {
              final sum = validReviews.fold<double>(0, (sum, review) => sum + review.rating);
              averageRating = sum / validReviews.length;
            }
          }

          // Update product with calculated rating and review count
          products.add(ProductModel(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            originalPrice: product.originalPrice,
            discount: product.discount,
            imageUrl: product.imageUrl,
            images: product.images,
            category: product.category as CategoryModel,
            rating: averageRating,
            reviewCount: reviews.length,
            isNew: product.isNew,
            stockQuantity: product.stockQuantity,
            specifications: product.specifications,
            createdAt: product.createdAt,
          ));

          print('Product: ${product.name}, Calculated Rating: $averageRating, Reviews: ${reviews.length}');
        }

        final hasMore = response.data['meta']?['pagination']?['hasNextPage'] ?? false;

        return {
          'products': products,
          'hasMore': hasMore,
        };
      } else {
        throw ServerException('Failed to load products');
      }
    } catch (e) {
      print('Exception in getProducts: $e');
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await client.get(
        '/products',
        queryParameters: {
          'filters[id][\$eq]': id,
          'populate': '*',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];

        if (data is List && data.isNotEmpty) {
          final productItem = data.first;

          if (productItem is Map && productItem['attributes'] != null) {
            final attributes = productItem['attributes'] as Map<String, dynamic>;
            attributes['id'] = productItem['id'];
            final product = ProductModel.fromJson(attributes);

            // Fetch reviews for this product
            final reviews = await reviewRemoteDataSource.getProductReviews(product.id);
            double averageRating = 0.0;
            if (reviews.isNotEmpty) {
              final validReviews = reviews.where((review) => review.rating > 0).toList();
              if (validReviews.isNotEmpty) {
                final sum = validReviews.fold<double>(0, (sum, review) => sum + review.rating);
                averageRating = sum / validReviews.length;
              }
            }

            return ProductModel(
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price,
              originalPrice: product.originalPrice,
              discount: product.discount,
              imageUrl: product.imageUrl,
              images: product.images,
              category: product.category as CategoryModel,
              rating: averageRating,
              reviewCount: reviews.length,
              isNew: product.isNew,
              stockQuantity: product.stockQuantity,
              specifications: product.specifications,
              createdAt: product.createdAt,
            );
          }

          if (productItem is Map) {
            final product = ProductModel.fromJson(productItem.cast<String, dynamic>());
            final reviews = await reviewRemoteDataSource.getProductReviews(product.id);
            double averageRating = 0.0;
            if (reviews.isNotEmpty) {
              final validReviews = reviews.where((review) => review.rating > 0).toList();
              if (validReviews.isNotEmpty) {
                final sum = validReviews.fold<double>(0, (sum, review) => sum + review.rating);
                averageRating = sum / validReviews.length;
              }
            }

            return ProductModel(
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price,
              originalPrice: product.originalPrice,
              discount: product.discount,
              imageUrl: product.imageUrl,
              images: product.images,
              category: product.category as CategoryModel,
              rating: averageRating,
              reviewCount: reviews.length,
              isNew: product.isNew,
              stockQuantity: product.stockQuantity,
              specifications: product.specifications,
              createdAt: product.createdAt,
            );
          }
        }

        throw ProductNotFoundException('Product with ID: $id not found');
      } else {
        throw ServerException('Failed to fetch product with ID: $id');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ProductNotFoundException('Product with ID: $id not found');
      }
      throw ServerException(_mapDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  String _mapSortOption(String sortOption) {
    switch (sortOption) {
      case 'newest':
        return 'createdAt:desc';
      case 'priceLowToHigh':
        return 'price:asc';
      case 'priceHighToLow':
        return 'price:desc';
      case 'rating':
        return 'createdAt:desc'; // We'll sort by rating client-side after calculating averages
      default:
        return 'createdAt:desc';
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout while fetching data';
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection';
      default:
        return 'An unexpected error occurred: ${e.message}';
    }
  }
}