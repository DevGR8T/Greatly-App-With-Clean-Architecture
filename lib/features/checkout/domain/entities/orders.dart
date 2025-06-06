import 'package:equatable/equatable.dart';
import 'address.dart';
import 'cart_item.dart';
import 'payment_method.dart';

enum OrderStatus {
  pending,
  paymentPending,
  paid,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class OrderEntity extends Equatable {
  final String? id; // May be null when creating an order
  final String userId;
  final List<CartItem> items;
  final Address shippingAddress;
  final Address? billingAddress; // Can be same as shipping
  final PaymentMethod? paymentMethod;
  final String? paymentIntentId; // Stripe payment intent ID
  final String? clientSecret; // For Stripe payment sheet
  final OrderStatus status;
  final double subtotal;
  final double shippingCost;
  final double taxAmount;
  final double discount;
  final double total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderEntity({
    this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    this.billingAddress,
    this.paymentMethod,
    this.paymentIntentId,
    this.clientSecret,
    this.status = OrderStatus.pending,
    required this.subtotal,
    required this.shippingCost,
    required this.taxAmount,
    this.discount = 0.0,
    required this.total,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        shippingAddress,
        billingAddress,
        paymentMethod,
        paymentIntentId,
        clientSecret,
        status,
        subtotal,
        shippingCost,
        taxAmount,
        discount,
        total,
        createdAt,
        updatedAt,
      ];
}