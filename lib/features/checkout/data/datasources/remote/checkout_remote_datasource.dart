import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greatly_user/features/checkout/domain/entities/address.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../models/address_model.dart';
import '../../models/order_model.dart';
import '../../models/payment_method_model.dart';
import '../../models/payment_result_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom exception for payment-related errors, extending [ServerException].
class PaymentException extends ServerException {
  final String code;
  final String userMessage;

  PaymentException(
    this.code,
    this.userMessage,
    String technicalMessage,
  ) : super(technicalMessage);
}

/// Abstract data source for checkout-related remote operations.
abstract class CheckoutRemoteDataSource {
  /// Retrieves all saved addresses for the currently authenticated user.
  Future<List<AddressModel>> getSavedAddresses();

  /// Saves a new address for the currently authenticated user.
  Future<AddressModel> saveAddress(Address address);

  /// Retrieves all payment methods saved by the current user.
  Future<List<PaymentMethodModel>> getSavedPaymentMethods();

  /// Deletes an address by its ID.
  Future<bool> deleteAddress(String addressId);

  /// Creates an order with the given cart items and addresses.
  /// Returns the order model including payment intent.
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required Address shippingAddress,
    Address? billingAddress,
    String? selectedPaymentMethodId,
    String? couponCode,
  });

  /// Initializes payment for an order and returns the updated order.
  Future<OrderModel> initializePayment({
    required String orderId,
    String? paymentMethodId,
  });

  /// Confirms a payment for an order using the payment intent ID.
  Future<PaymentResultModel> confirmPayment({
    required String orderId,
    required String paymentIntentId,
  });

  /// Cancels an order that has not been paid for.
  Future<bool> cancelOrder({required String orderId});

  /// Retrieves order details by order ID.
  Future<OrderModel> getOrderById({required String orderId});

  /// Retrieves all orders for the current user with optional pagination.
  Future<List<OrderModel>> getUserOrders({int? page, int? limit});

  /// Adds a payment method to the current user's account.
  Future<PaymentMethodModel> addPaymentMethod({
    required String paymentMethodId,
    bool isDefault = false,
  });

  /// Deletes a payment method from the user's account.
  Future<bool> deletePaymentMethod({
    required String paymentMethodId,
  });

  /// Sets a payment method as the default for the user.
  Future<bool> setDefaultPaymentMethod({
    required String paymentMethodId,
  });

  /// Creates a Stripe setup intent for adding a new payment method.
  Future<Map<String, dynamic>> createSetupIntent();

  /// Creates a billing portal session for the user to manage payment methods.
  Future<String> createPortalSession();

  /// Creates a Stripe portal session for the user with the option to specify a return URL.
  Future<String> createStripePortalSession({
    required String customerEmail,
    required String firebaseUid,
    String? returnUrl,
  });

  /// Calculates the subtotal from cart items
  double calculateSubtotal(List<Map<String, dynamic>> cartItems);

  /// Calculates tax amount from cart items
  double calculateTax(List<Map<String, dynamic>> cartItems);

  /// Calculates the total amount including tax and shipping
  double calculateTotal(List<Map<String, dynamic>> cartItems);
}

/// Implementation of [CheckoutRemoteDataSource] using Dio and Firebase Auth.
@LazySingleton(as: CheckoutRemoteDataSource)
class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final DioClient _dioClient;
  final FirebaseAuth _firebaseAuth;

  CheckoutRemoteDataSourceImpl({
    required DioClient dioClient,
    required FirebaseAuth firebaseAuth,
  })  : _dioClient = dioClient,
        _firebaseAuth = firebaseAuth;

  /// Log informational messages for debugging and monitoring.
  void _logInfo(String method, String message, [Map<String, dynamic>? data]) {
    print('[INFO] [$method] $message');
    if (data != null) {
      print('[DATA] [$method] ${json.encode(data)}');
    }
  }

  /// Log error messages for troubleshooting, including error details and optional stack trace.
  void _logError(String method, String message, dynamic error,
      [StackTrace? stackTrace]) {
    print('[ERROR] [$method] $message');
    print('[ERROR] [$method] Error: $error');
    if (stackTrace != null) {
      print('[ERROR] [$method] Stack trace: $stackTrace');
    }
  }

  @override
  double calculateSubtotal(List<Map<String, dynamic>> cartItems) {
    return cartItems.fold(0.0, (total, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return total + (price * quantity);
    });
  }

  @override
  double calculateTax(List<Map<String, dynamic>> cartItems) {
    final subtotal = calculateSubtotal(cartItems);
    const taxRate = 0.10; // 10% tax rate - adjust as needed
    return subtotal * taxRate;
  }

  @override
  double calculateTotal(List<Map<String, dynamic>> cartItems) {
    final subtotal = calculateSubtotal(cartItems);
    final tax = calculateTax(cartItems);
    const shippingCost =
        10.0; // Should match the hardcoded value in createOrder
    return subtotal + tax + shippingCost;
  }

  /// Retrieves the current user's Firebase authentication token, with retry and error handling.
  Future<String> _getAuthToken() async {
    const method = 'getAuthToken';
    _logInfo(method, 'Attempting to get auth token');

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw UnauthorizedException('User not authenticated');
      }
      final token = await user.getIdToken(true);

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('Failed to obtain authentication token');
      }

      _logInfo(method, 'Auth token obtained successfully');
      return token;
    } catch (e, stackTrace) {
      _logError(method, 'Failed to get auth token', e, stackTrace);
      if (e is UnauthorizedException) rethrow;
      throw UnauthorizedException('Authentication failed: ${e.toString()}');
    }
  }

  /// Returns the currently authenticated Firebase user or throws if not authenticated.
  User _getCurrentUser() {
    const method = 'getCurrentUser';
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      _logError(method, 'User not authenticated', 'currentUser is null');
      throw UnauthorizedException('User not authenticated');
    }

    _logInfo(method, 'Current user retrieved',
        {'uid': user.uid, 'email': user.email});
    return user;
  }

 
/// Handles API responses, ensuring valid status and parsing data using the provided parser.
T _handleApiResponse<T>(
  String method,
  Response response,
  T Function(dynamic data) parser,
) {
  _logInfo(method, 'API response received', {
    'statusCode': response.statusCode,
    'hasData': response.data != null,
  });

  if (response.statusCode == null ||
      response.statusCode! < 200 ||
      response.statusCode! >= 300) {
    throw ServerException('API returned status ${response.statusCode}');
  }

  try {
    // Handle Strapi response format
    final responseData = response.data;
    
    // Log the full response for debugging
    print('DEBUG: Full response data: $responseData');
    
    // Check if it's a Strapi response with nested data
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      // Standard Strapi format: { "data": { ... }, "meta": { ... } }
      return parser(responseData['data']);
    } else if (responseData is Map<String, dynamic> && 
               responseData.containsKey('statusCode') && 
               responseData.containsKey('hasData')) {
      // Your custom response format - but no actual data
      throw ServerException('Server response contains no data: $responseData');
    } else {
      // Direct data format
      return parser(responseData);
    }
  } catch (e, stackTrace) {
    _logError(method, 'Failed to parse response data', e, stackTrace);
    throw ServerException('Failed to parse server response: ${e.toString()}');
  }
}

  @override
  Future<List<AddressModel>> getSavedAddresses() async {
    const method = 'getSavedAddresses';
    _logInfo(method, 'Starting address retrieval');

    try {
      final user = _getCurrentUser();

      _logInfo(method, 'Making API request');
      final response = await _dioClient.get(
        '/address-collections',
        queryParameters: {'filters[firebase_user_id][\$eq]': user.uid},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null || data is! List) {
          return [];
        }
        return data
            .map<AddressModel>((json) =>
                AddressModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception('Failed to retrieve addresses: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logError(method, 'Failed to get saved addresses', e, stackTrace);
      throw Exception('Failed to retrieve addresses: ${e.toString()}');
    }
  }

  @override
  Future<AddressModel> saveAddress(Address address) async {
    const method = 'saveAddress';
    _logInfo(method, 'Saving address');

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      final addressModel =
          address is AddressModel ? address : AddressModel.fromEntity(address);

      final addressJson = addressModel.toJson();
      addressJson['firebase_user_id'] = user.uid;

      final response = await _dioClient.post(
        '/address-collections',
        data: {
          'data': addressJson,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final addressData = responseData['data'] ?? responseData;
        final finalData = addressData['attributes'] ?? addressData;

        return AddressModel.fromJson(Map<String, dynamic>.from(finalData));
      } else {
        throw Exception('Failed to save address: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logError(method, 'Failed to save address', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw ServerException('Failed to save address: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteAddress(String addressId) async {
    try {
      final user = _getCurrentUser();

      final response = await _dioClient.delete(
        '/address-collections/$addressId',
        queryParameters: {
          'firebaseUserId': user.uid,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException('Failed to delete address');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete address');
    }
  }

  @override
  Future<List<PaymentMethodModel>> getSavedPaymentMethods() async {
    const method = 'getSavedPaymentMethods';
    _logInfo(method, 'Starting payment methods retrieval');

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      _logInfo(method, 'Making API request');
      final response = await _dioClient.get(
        '/payment-method-collections',
        queryParameters: {'firebaseUserId': user.uid},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _handleApiResponse(
        method,
        response,
        (data) {
          List results;
          if (data is List) {
            results = data;
          } else if (data is Map && data.containsKey('results')) {
            results = data['results'];
          } else if (data is Map && data.containsKey('data')) {
            results = data['data'];
          } else {
            throw ServerException(
                'Unexpected response format: ${data.runtimeType}');
          }

          return results
              .map<PaymentMethodModel>(
                  (json) => PaymentMethodModel.fromJson(json))
              .toList();
        },
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to get saved payment methods', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw ServerException(
          'Failed to retrieve payment methods: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required Address shippingAddress,
    Address? billingAddress,
    String? selectedPaymentMethodId,
    String? couponCode,
  }) async {
    const method = 'createOrder';
    _logInfo(method, 'Starting order creation', {
      'itemCount': cartItems.length,
      'hasPaymentMethod': selectedPaymentMethodId != null,
      'hasCoupon': couponCode != null,
    });

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      if (cartItems.isEmpty) {
        throw ServerException('Cannot create order with empty cart');
      }

      final shippingAddressJson =
          _convertAddressToJson(shippingAddress, 'shipping');
      final billingAddressJson = billingAddress != null
          ? _convertAddressToJson(billingAddress, 'billing')
          : null;

      _logInfo(method, 'Making API request');
      final response = await _dioClient.post(
        '/order-collections',
        data: {
          'data': {
            'userId': user.uid,
            'userEmail': user.email,
            'items': cartItems,
            'shippingAddress': shippingAddressJson,
            'billingAddress': billingAddressJson,
            'paymentMethodId': selectedPaymentMethodId,
            'couponCode': couponCode,
            'orderStatus': 'pending',
            'subtotal': calculateSubtotal(cartItems),
            'shippingCost': 10.0,
            'taxAmount': calculateTax(cartItems),
            'discount': 0.0,
            'total': calculateTotal(cartItems),
          }
        },
        options: Options(
          headers: {
            //  'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return _handleApiResponse(
        method,
        response,
        (data) => OrderModel.fromJson(data,
            currentUserId: user.uid), // Add currentUserId
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to create order', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw ServerException('Failed to create order: ${e.toString()}');
    }
  }

  /// Converts an [Address] or [AddressModel] into a JSON map for API requests.
  Map<String, dynamic> _convertAddressToJson(Address address, String type) {
    try {
      if (address is AddressModel) {
        return address.toJson();
      } else {
        return AddressModel.fromEntity(address).toJson();
      }
    } catch (e) {
      throw ServerException('Invalid $type address format: ${e.toString()}');
    }
  }

@override
Future<OrderModel> initializePayment({
  required String orderId,
  String? paymentMethodId,
}) async {
  const method = 'initializePayment';
  _logInfo(method, 'Starting payment initialization', {
    'orderId': orderId,
    'hasPaymentMethod': paymentMethodId != null,
  });

  try {
    final user = _getCurrentUser();
    final token = await _getAuthToken();

    _logInfo(method, 'Making API request');
    final response = await _dioClient.post(
      '/orders/$orderId/payment',
      data: {
        'userId': user.uid,
        'paymentMethodId': paymentMethodId,
      },
      options: Options(
        headers: {
         // 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    final order = _handleApiResponse(
      method,
      response,
      (data) => OrderModel.fromJson(data),
    );

    // Check if we have a client secret from the payment intent
    String? clientSecret = order.clientSecret;
    
    // If not in order, try to get it from the response
    if (clientSecret?.isEmpty ?? true) {
      clientSecret = response.data['data']?['payment_intent']?['client_secret'];
    }

    if (clientSecret?.isNotEmpty == true) {
      _logInfo(method, 'Initializing Stripe payment sheet');
      try {
        await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: stripe.SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret!,
            merchantDisplayName: 'Your Store Name',
            style: ThemeMode.system,
          ),
        );
        _logInfo(method, 'Stripe payment sheet initialized successfully');
      } catch (stripeError) {
        _logError(
            method, 'Failed to initialize Stripe payment sheet', stripeError);
        throw PaymentException(
          'stripe_init_failed',
          'Failed to initialize payment. Please try again.',
          stripeError.toString(),
        );
      }
    } else {
      throw PaymentException(
        'missing_client_secret',
        'Payment initialization failed - missing client secret',
        'No client secret received from server',
      );
    }

    return order;
  } catch (e, stackTrace) {
    _logError(method, 'Failed to initialize payment', e, stackTrace);
    if (e is UnauthorizedException ||
        e is ServerException ||
        e is PaymentException) rethrow;
    throw ServerException('Failed to initialize payment: ${e.toString()}');
  }
}

  @override
  Future<PaymentResultModel> confirmPayment({
    required String orderId,
    required String paymentIntentId,
  }) async {
    const method = 'confirmPayment';
    _logInfo(method, 'Starting payment confirmation', {
      'orderId': orderId,
      'paymentIntentId': paymentIntentId,
    });

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      _logInfo(method, 'Making API request');
      final response = await _dioClient.post(
        '/order-collections/$orderId/confirm',
        data: {
          'userId': user.uid,
          'paymentIntentId': paymentIntentId,
        },
        options: Options(
          headers: {
           // 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return _handleApiResponse(
        method,
        response,
        (data) => PaymentResultModel.fromJson(data),
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to confirm payment', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw ServerException('Failed to confirm payment: ${e.toString()}');
    }
  }

  @override
  Future<bool> cancelOrder({required String orderId}) async {
    const method = 'cancelOrder';
    _logInfo(method, 'Starting order cancellation', {'orderId': orderId});

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      _logInfo(method, 'Making API request');
      final response = await _dioClient.post(
        '/orders/$orderId/cancel',
        data: {'userId': user.uid},
        options: Options(
          headers: {
           // 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return _handleApiResponse(
        method,
        response,
        (data) {
          final success = data['success'] ?? false;
          _logInfo(method, 'Order cancellation result', {'success': success});
          return success as bool;
        },
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to cancel order', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw ServerException('Failed to cancel order: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderById({required String orderId}) async {
    const method = 'getOrderById';
    _logInfo(method, 'Starting order retrieval', {'orderId': orderId});

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      _logInfo(method, 'Making API request');
      final response = await _dioClient.get(
        '/order-collections/$orderId',
        queryParameters: {'userId': user.uid},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _handleApiResponse(
        method,
        response,
        (data) => OrderModel.fromJson(data,
            currentUserId: user.uid), // Add currentUserId
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to get order by ID', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw ServerException('Failed to retrieve order: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders({int? page, int? limit}) async {
    const method = 'getUserOrders';
    _logInfo(method, 'Starting user orders retrieval', {
      'page': page,
      'limit': limit,
    });

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      _logInfo(method, 'Making API request');
      final response = await _dioClient.get(
        '/order-collections',
        queryParameters: {
          'userId': user.uid,
          if (page != null) 'page': page.toString(),
          if (limit != null) 'limit': limit.toString(),
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return _handleApiResponse(
  method,
  response,
  (data) {
    if (data is! List) {
      throw ServerException(
          'Expected list of orders but got ${data.runtimeType}');
    }
    _logInfo(method, 'Parsing ${data.length} orders');
    return data
        .map<OrderModel>((json) => OrderModel.fromJson(json, currentUserId: user.uid)) // Add currentUserId
        .toList();
  },
);
    } catch (e, stackTrace) {
      _logError(method, 'Failed to get user orders', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw ServerException('Failed to retrieve orders: ${e.toString()}');
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod({
    required String paymentMethodId,
    bool isDefault = false,
  }) async {
    const method = 'addPaymentMethod';
    _logInfo(method, 'Starting payment method addition', {
      'paymentMethodId': paymentMethodId,
      'isDefault': isDefault,
    });

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      if (user.email == null || user.email!.isEmpty) {
        throw UnauthorizedException(
            'User email is required for payment methods');
      }

      _logInfo(method, 'Making API request');
      final response = await _dioClient.post(
        '/payment-method-collections',
        data: {
          'firebase_user_id': user.uid,
          'stripe_payment_method_id': paymentMethodId,
          'is_default': isDefault,
          'email': user.email,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return _handleApiResponse(
        method,
        response,
        (data) {
          if (data['success'] != true) {
            throw ServerException('Payment method was not added successfully');
          }
          return PaymentMethodModel.fromJson(data['paymentMethod'] ?? data);
        },
      );
    } on DioException catch (e) {
      _logError(method, 'DioException occurred', e);
      String errorMessage = 'Failed to add payment method';

      if (e.response?.statusCode == 409) {
        errorMessage = 'This payment method is already saved';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid payment method';
      }

      throw PaymentException(
        'add_payment_method_failed',
        errorMessage,
        e.toString(),
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to add payment method', e, stackTrace);
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is PaymentException) {
        rethrow;
      }
      throw ServerException('Failed to add payment method: ${e.toString()}');
    }
  }

  @override
  Future<bool> deletePaymentMethod({
    required String paymentMethodId,
  }) async {
    const method = 'deletePaymentMethod';
    _logInfo(method, 'Starting payment method deletion', {
      'paymentMethodId': paymentMethodId,
    });

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      final response = await _dioClient.delete(
        '/payment-method-collections/$paymentMethodId',
        queryParameters: {'firebaseUserId': user.uid},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      return _handleApiResponse(
        method,
        response,
        (data) {
          final success = data['success'] ?? false;
          _logInfo(
              method, 'Payment method deletion result', {'success': success});
          return success as bool;
        },
      );
    } on DioException catch (e) {
      _logError(method, 'DioException occurred', e);
      String errorMessage = 'Failed to delete payment method';

      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage =
            'Request timed out. Please check your connection and try again.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Payment method not found';
      } else if (e.response?.statusCode == 403) {
        errorMessage =
            'Cannot delete default payment method. Set another as default first.';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid request';
      }

      throw PaymentException(
        'delete_payment_method_failed',
        errorMessage,
        e.toString(),
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to delete payment method', e, stackTrace);
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is PaymentException) {
        rethrow;
      }
      throw ServerException('Failed to delete payment method: ${e.toString()}');
    }
  }

  @override
  Future<bool> setDefaultPaymentMethod({
    required String paymentMethodId,
  }) async {
    const method = 'setDefaultPaymentMethod';
    _logInfo(method, 'Starting default payment method update', {
      'paymentMethodId': paymentMethodId,
    });

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      _logInfo(method, 'Making API request');
      final response = await _dioClient.post(
        '/payment-methods/$paymentMethodId/set-default',
        data: {'firebase_user_id': user.uid},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return _handleApiResponse(
        method,
        response,
        (data) {
          final success = data['success'] ?? false;
          _logInfo(method, 'Set default payment method result',
              {'success': success});
          return success as bool;
        },
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to set default payment method', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw ServerException(
          'Failed to set default payment method: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> createSetupIntent() async {
    const method = 'createSetupIntent';
    _logInfo(method, 'Starting setup intent creation');

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      if (user.email == null || user.email!.isEmpty) {
        throw UnauthorizedException('User email is required for setup intent');
      }

      _logInfo(method, 'Making API request to: /payment/setup-intent');
      final response = await _dioClient.post(
        '/payment/setup-intent',
        data: {
          'firebase_user_id': user.uid,
          'email': user.email,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return _handleApiResponse(
        method,
        response,
        (data) {
          if (data['client_secret'] == null) {
            throw ServerException('Setup intent client secret not provided');
          }
          _logInfo(method, 'Setup intent created successfully');
          return Map<String, dynamic>.from(data);
        },
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to create setup intent', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw PaymentException(
        'setup_intent_failed',
        'Failed to initialize payment setup. Please try again.',
        e.toString(),
      );
    }
  }

  @override
  Future<String> createPortalSession() async {
    const method = 'createPortalSession';
    _logInfo(method, 'Starting portal session creation');

    try {
      final user = _getCurrentUser();
      final token = await _getAuthToken();

      if (user.email == null || user.email!.isEmpty) {
        throw UnauthorizedException(
            'User email is required for portal session');
      }

      final requestData = {
        'customer_email': user.email!,
        'firebase_uid': user.uid,
        'return_url': 'localhost:1337//payment-complete',
      };

      _logInfo(
          method,
          'Making API request to: /payment-method-collections/create-portal-session',
          requestData);

      final response = await _dioClient.post(
        '/payment-method-collections/create-portal-session',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return _handleApiResponse(
        method,
        response,
        (data) {
          if (data['url'] == null) {
            throw ServerException('Portal session URL not provided');
          }
          _logInfo(method, 'Portal session created successfully');
          return data['url'] as String;
        },
      );
    } catch (e, stackTrace) {
      _logError(method, 'Failed to create portal session', e, stackTrace);
      if (e is UnauthorizedException || e is ServerException) rethrow;
      throw PaymentException(
        'portal_session_failed',
        'Failed to open payment management. Please try again.',
        e.toString(),
      );
    }
  }

  /// Opens the Stripe billing portal in an external browser using [url_launcher].
  Future<void> openPaymentPortal() async {
    const method = 'openPaymentPortal';
    _logInfo(method, 'Opening payment portal');

    try {
      final portalUrl = await createPortalSession();

      final Uri url = Uri.parse(portalUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        _logInfo(method, 'Portal opened successfully');
      } else {
        throw PaymentException(
          'launch_failed',
          'Could not open payment portal',
          'Cannot launch URL: $portalUrl',
        );
      }
    } catch (e, stackTrace) {
      _logError(method, 'Failed to open payment portal', e, stackTrace);
      rethrow;
    }
  }

  /// Creates a Stripe portal session for the user and returns the portal URL.
  Future<String> createStripePortalSession({
    required String customerEmail,
    required String firebaseUid,
    String? returnUrl,
  }) async {
    try {
      final data = {
        'customer_email': customerEmail,
        'firebase_uid': firebaseUid,
        'return_url': returnUrl ?? 'about:blank',
      };

      final response = await _dioClient.post(
        '/payment-method-collections/create-portal-session',
        data: data,
      );

      if (response.statusCode != 200 || response.data == null) {
        throw ServerException('Failed to create Stripe portal session');
      }

      String? portalUrl;
      if (response.data is Map<String, dynamic>) {
        portalUrl = response.data['url'] as String?;
      } else if (response.data is String) {
        final decoded = json.decode(response.data);
        portalUrl = decoded['url'] as String?;
      }

      if (portalUrl == null || portalUrl.isEmpty) {
        throw ServerException('Stripe portal URL not found in response');
      }

      return portalUrl;
    } catch (e) {
      throw ServerException('Error creating Stripe portal session: $e');
    }
  }
}
