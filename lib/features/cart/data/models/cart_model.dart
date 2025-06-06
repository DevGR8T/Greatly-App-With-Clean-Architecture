import 'dart:convert';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import 'cart_item_model.dart';

class CartModel extends Cart {
  const CartModel({
    required String id,
    required List<CartItem> items,
    required double totalPrice,
  }) : super(
          id: id,
          items: items,
          totalPrice: totalPrice,
        );

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)
            ?.map((item) => CartItemModel.fromJson(item))
            .toList() ??
        [];
    final totalPrice = (json['total_price'] is int)
        ? (json['total_price'] as int).toDouble()
        : json['total_price']?.toDouble() ?? 0.0;
    return CartModel(
      id: json['id'] ?? '',
      items: itemsList,
      totalPrice: totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items
          .map((item) =>
              item is CartItemModel ? item.toJson() : CartItemModel.fromEntity(item).toJson())
          .toList(),
      'total_price': totalPrice,
    };
  }

  factory CartModel.fromEntity(Cart cart) {
    return CartModel(
      id: cart.id,
      items: cart.items
          .map((item) => CartItemModel.fromEntity(item))
          .toList(),
      totalPrice: cart.totalPrice,
    );
  }

  factory CartModel.empty() {
    return const CartModel(
      id: '',
      items: [],
      totalPrice: 0.0,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory CartModel.fromJsonString(String source) =>
      CartModel.fromJson(json.decode(source));
}