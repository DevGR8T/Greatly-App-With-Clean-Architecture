import 'dart:async';
import 'package:dartz/dartz.dart' hide Order;
import 'package:greatly_user/features/checkout/domain/entities/orders.dart';
import '../entities/address.dart';
import '../entities/payment_method.dart';
import '../entities/payment_result.dart';
import '../../../../core/error/failure.dart';

abstract class CheckoutRepository {
  /// Retrieves saved addresses for the current user
  Future<Either<Failure, List<Address>>> getSavedAddresses();
  
  /// Saves a new address or updates an existing one
  Future<Either<Failure, Address>> saveAddress(Address address);
  
  /// Deletes an existing address by ID
  Future<Either<Failure, bool>> deleteAddress(String addressId);

  /// Retrieves saved payment methods for the current user
  Future<Either<Failure, List<PaymentMethod>>> getSavedPaymentMethods();

  /// Creates an order and returns payment intent for processing
  Future<Either<Failure, OrderEntity>> createOrder({
    required List<Map<String, dynamic>> cartItems,
    required Address shippingAddress,
    Address? billingAddress,
    String? selectedPaymentMethodId,
    String? couponCode,
  });

  /// Initializes the payment process, creates payment intent on Stripe
  Future<Either<Failure, OrderEntity>> initializePayment({
    required String orderId,
    String? paymentMethodId,
  });

  /// Confirms the payment was successful and updates the order status
  Future<Either<Failure, PaymentResult>> confirmPayment({
    required String orderId,
    required String paymentIntentId,
  });

  /// Cancel an order that hasn't been paid for yet
  Future<Either<Failure, bool>> cancelOrder({
    required String orderId,
  });

  /// Get order by ID
  Future<Either<Failure, OrderEntity>> getOrderById({
    required String orderId,
  });

  /// Get list of user's orders
  Future<Either<Failure, List<OrderEntity>>> getUserOrders({
    int? page,
    int? limit,
  });

  /// Add a payment method to the user's account
  Future<Either<Failure, bool>> addPaymentMethod({
    required String paymentMethodId,
    bool isDefault = false,
  });

  /// Delete a payment method from user's account
  Future<Either<Failure, bool>> deletePaymentMethod({
    required String paymentMethodId,
  });

  /// Create Stripe Customer Portal session for managing payment methods
  Future<Either<Failure, String>> createStripePortalSession({
    required String customerEmail,
    required String firebaseUid,
    String? returnUrl,
  });
}
