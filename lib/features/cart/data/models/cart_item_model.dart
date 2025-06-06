import 'dart:convert';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required String id,
    required String productId,
    required String name,
    String imageUrl = '',
    String variant = '',
    required int quantity,
    required double price,
  }) : super(
          id: id,
          productId: productId,
          name: name,
          imageUrl: imageUrl,
          variant: variant,
          quantity: quantity,
          price: price,
        );

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      variant: json['variant'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'image_url': imageUrl,
      'variant': variant,
      'quantity': quantity,
      'price': price,
    };
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      id: item.id,
      productId: item.productId,
      name: item.name,
      imageUrl: item.imageUrl,
      variant: item.variant,
      quantity: item.quantity,
      price: item.price,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory CartItemModel.fromJsonString(String source) =>
      CartItemModel.fromJson(json.decode(source));
}