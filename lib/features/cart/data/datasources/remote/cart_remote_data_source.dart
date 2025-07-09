// Remote data source fix - Improved error handling and response parsing
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/cart_model.dart';
import '../../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addToCart(CartItemModel item);
  Future<CartModel> updateCartItem(CartItemModel item);
  Future<CartModel> removeFromCart(String itemId);
  Future<CartModel> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioClient dioClient;
  final FirebaseAuth _firebaseAuth;

  CartRemoteDataSourceImpl({
    required this.dioClient,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Helper method to get the current user ID from Firebase
  String? get _userId => _firebaseAuth.currentUser?.uid;

  // Helper to add auth headers to requests if needed
  Future<Map<String, dynamic>> _getAuthHeaders() async {
    try {
      final token = await _firebaseAuth.currentUser?.getIdToken();
      return {
        if (token != null) 'Authorization': 'Bearer $token',
      };
    } catch (e) {
      // Handle token retrieval errors gracefully

      return {};
    }
  }

  @override
  Future<CartModel> getCart() async {
    try {
      final headers = await _getAuthHeaders();
      
      // Add timeout options to avoid long waiting times
      final options = Options(
        headers: headers,
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      );
      
      final response = await dioClient.get(
        '/cart',
        options: options,
      );
      
      // More robust response parsing with null safety
      if (response.data == null) {
        throw ServerException('Empty response received');
      }
      
      final data = response.data['data'];
      if (data == null) {
        // If server returns a valid response but without data field,
        // return an empty cart instead of crashing
        return CartModel.empty();
      }
      
      return CartModel.fromJson(data);
    } on DioException catch (e) {
      // More detailed error message based on DioError type
      final String errorMessage = _handleDioError(e);
      throw ServerException(errorMessage);
    } catch (e) {
      // Handle any other unexpected errors
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  // Helper method to provide better error messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again later.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again later.';
      case DioExceptionType.badResponse:
        // Handle different HTTP status codes
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          return 'Cart not found. Please try again.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Server returned error code: $statusCode';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return e.message ?? 'Unknown network error occurred.';
    }
  }

  @override
  Future<CartModel> addToCart(CartItemModel item) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await dioClient.post(
        '/cart/items',
        data: item.toJson(),
        options: Options(headers: headers),
      );
      
      if (response.data == null || response.data['data'] == null) {
        return CartModel.empty();
      }
      
      return CartModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> updateCartItem(CartItemModel item) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await dioClient.put(
        '/cart/items/${item.id}',
        data: item.toJson(),
        options: Options(headers: headers),
      );
      
      if (response.data == null || response.data['data'] == null) {
        return CartModel.empty();
      }
      
      return CartModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> removeFromCart(String itemId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await dioClient.delete(
        '/cart/items/$itemId',
        options: Options(headers: headers),
      );
      
      if (response.data == null || response.data['data'] == null) {
        return CartModel.empty();
      }
      
      return CartModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<CartModel> clearCart() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await dioClient.delete(
        '/cart',
        options: Options(headers: headers),
      );
      
      if (response.data == null || response.data['data'] == null) {
        return CartModel.empty();
      }
      
      return CartModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}