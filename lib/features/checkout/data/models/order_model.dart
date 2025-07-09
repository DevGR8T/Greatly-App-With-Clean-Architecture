import '../../domain/entities/orders.dart';
import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../models/payment_method_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    super.id,
    required super.userId,
    required super.items,
    required super.shippingAddress,
    super.billingAddress,
    super.paymentMethod,
    super.paymentIntentId,
    super.clientSecret,
    super.status = OrderStatus.pending,
    required super.subtotal,
    required super.shippingCost,
    required super.taxAmount,
    super.discount = 0.0,
    required super.total,
    super.createdAt,
    super.updatedAt,
  });

factory OrderModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {



  
  // Handle the nested response structure from your payment API
  Map<String, dynamic> data;
  
  if (json.containsKey('data') && json['data'] is Map) {
    final responseData = json['data'] as Map<String, dynamic>;

    
    // Check if this is the payment response format
    if (responseData.containsKey('order') && responseData['order'] is Map) {
      data = responseData['order'] as Map<String, dynamic>;

    } else {
      data = responseData;

    }
  } else if (json.containsKey('order') && json['order'] is Map) {
    // Handle case where order is at root level
    data = json['order'] as Map<String, dynamic>;

  } else {
    data = json;

  }
  




  
  return OrderModel(
    id: data['id']?.toString(),
    userId: currentUserId ?? data['userId']?.toString() ?? '', 
    items: data['items'] != null 
      ? (data['items'] as List).map((item) {
          final fixedItem = Map<String, dynamic>.from(item);
          if (fixedItem['id'] != null) fixedItem['id'] = fixedItem['id'].toString();
          if (fixedItem['productId'] != null) fixedItem['productId'] = fixedItem['productId'].toString();
          return CartItemModel.fromJson(fixedItem);
        }).toList()
      : <CartItemModel>[],
    shippingAddress: AddressModel.fromJson({
      ...Map<String, dynamic>.from(data['shippingAddress'] ?? {}),
      'postal_code': data['shippingAddress']?['postal_code']?.toString() ?? "",
    }),
    billingAddress: data['billingAddress'] != null
        ? AddressModel.fromJson({
            ...Map<String, dynamic>.from(data['billingAddress']),
            'postal_code': data['billingAddress']['postal_code']?.toString() ?? "",
          })
        : null,
    paymentMethod: data['paymentMethod'] != null
        ? PaymentMethodModel.fromJson(data['paymentMethod'])
        : null,
    paymentIntentId: data['paymentIntentId']?.toString(),
    clientSecret: data['clientSecret']?.toString(),
    status: _mapStringToOrderStatus(data['orderStatus']?.toString() ?? 'pending'),
    subtotal: _parseToDouble(data['subtotal']),
    shippingCost: _parseToDouble(data['shippingCost']),
    taxAmount: _parseToDouble(data['taxAmount']),
    discount: _parseToDouble(data['discount']),
    total: _parseToDouble(data['total']),
    createdAt: data['createdAt'] != null
        ? DateTime.parse(data['createdAt'].toString())
        : null,
    updatedAt: data['updatedAt'] != null
        ? DateTime.parse(data['updatedAt'].toString())
        : null,
  );
}

// Helper method to safely parse numbers to double
static double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

factory OrderModel.fromEntity(OrderEntity order) {
  return OrderModel(
    id: order.id,
    userId: order.userId,
    items: order.items.map((item) {
      return item is CartItemModel
          ? item
          : CartItemModel.fromEntity(item);
    }).toList(),
    shippingAddress: order.shippingAddress is AddressModel
        ? order.shippingAddress as AddressModel
        : AddressModel.fromEntity(order.shippingAddress),
    billingAddress: order.billingAddress != null
        ? (order.billingAddress is AddressModel
            ? order.billingAddress as AddressModel
            : AddressModel.fromEntity(order.billingAddress!))
        : null,
    paymentMethod: order.paymentMethod != null
        ? (order.paymentMethod is PaymentMethodModel
            ? order.paymentMethod as PaymentMethodModel
            : PaymentMethodModel.fromEntity(order.paymentMethod!))
        : null,
    paymentIntentId: order.paymentIntentId,
    clientSecret: order.clientSecret,
    status: order.status,
    subtotal: order.subtotal,
    shippingCost: order.shippingCost,
    taxAmount: order.taxAmount,
    discount: order.discount,
    total: order.total,
    createdAt: order.createdAt,
    updatedAt: order.updatedAt,
  );
}

Map<String, dynamic> toJson() {
  final items = this.items.map((item) {
    if (item is CartItemModel) {
      return item.toJson();
    } else {
      return CartItemModel.fromEntity(item).toJson();
    }
  }).toList();

  final shippingAddress = this.shippingAddress is AddressModel
      ? (this.shippingAddress as AddressModel).toJson()
      : AddressModel.fromEntity(this.shippingAddress).toJson();

  final billingAddress = this.billingAddress != null
      ? (this.billingAddress is AddressModel
          ? (this.billingAddress as AddressModel).toJson()
          : AddressModel.fromEntity(this.billingAddress!).toJson())
      : null;

  final paymentMethod = this.paymentMethod != null
      ? (this.paymentMethod is PaymentMethodModel
          ? (this.paymentMethod as PaymentMethodModel).toJson()
          : PaymentMethodModel.fromEntity(this.paymentMethod!).toJson())
      : null;

  return {
    'id': id,
    'userId': userId,
    'items': items,
    'shippingAddress': shippingAddress,
    'billingAddress': billingAddress,
    'paymentMethod': paymentMethod,
    'paymentIntentId': paymentIntentId,
    'clientSecret': clientSecret,
    'status': _mapOrderStatusToString(status),
    'subtotal': subtotal,
    'shippingCost': shippingCost,
    'taxAmount': taxAmount,
    'discount': discount,
    'total': total,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

static OrderStatus _mapStringToOrderStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'paymentpending':
      return OrderStatus.paymentPending;
    case 'paid':
      return OrderStatus.paid;
    case 'processing':
      return OrderStatus.processing;
    case 'shipped':
      return OrderStatus.shipped;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'refunded':
      return OrderStatus.refunded;
    default:
      return OrderStatus.pending;
  }
}

static String _mapOrderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'pending';
    case OrderStatus.paymentPending:
      return 'paymentPending';
    case OrderStatus.paid:
      return 'paid';
    case OrderStatus.processing:
      return 'processing';
    case OrderStatus.shipped:
      return 'shipped';
    case OrderStatus.delivered:
      return 'delivered';
    case OrderStatus.cancelled:
      return 'cancelled';
    case OrderStatus.refunded:
      return 'refunded';
  }
}
}
