import 'package:dio/dio.dart';
import 'package:greatly_user/core/network/dio_client.dart';
import 'package:greatly_user/features/products/data/model/product_model.dart';
import '../../../../../core/error/exceptions.dart';

/// Interface for fetching products from a remote server.
abstract class ProductRemoteDataSource {
  /// Fetches a list of products with optional filters and pagination.
  Future<Map<String, dynamic>> getProducts({
    String? query,
    String? categoryId,
    String? sortOption,
    int page = 1,
  });

  /// Fetches a single product by its ID.
  Future<ProductModel> getProductById(String id);
}

/// Implementation of ProductRemoteDataSource using Dio for HTTP requests.
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient client;

  ProductRemoteDataSourceImpl(this.client);

  /// Fetches a paginated list of products from the API.
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
        'pagination[pageSize]': 10,
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
        final products = productsJsonList
            .map((json) => ProductModel.fromJson(json))
            .toList();

        final hasMore = response.data['meta']?['pagination']?['hasNextPage'] ?? false;

        return {
          'products': products,
          'hasMore': hasMore,
        };
      } else {
        throw ServerException('Failed to load products');
      }
    } catch (e) {
      throw ServerException('An unexpected error occurred: $e');
    }
  }

  /// Fetches a single product by its ID from the API.
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
            return ProductModel.fromJson(attributes);
          }

          if (productItem is Map) {
            return ProductModel.fromJson(productItem.cast<String, dynamic>());
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

  /// Maps sort options to API-compatible values.
  String _mapSortOption(String sortOption) {
    switch (sortOption) {
      case 'newest':
        return 'createdAt:desc';
      case 'priceLowToHigh':
        return 'price:asc';
      case 'priceHighToLow':
        return 'price:desc';
      case 'rating':
        return 'rating:desc';
      default:
        return 'createdAt:desc';
    }
  }

  /// Maps Dio exceptions to user-friendly error messages.
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