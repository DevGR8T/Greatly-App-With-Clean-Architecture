import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final String variant;
  final int quantity;
  final double price;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    this.imageUrl = '',
    this.variant = '',
    required this.quantity,
    required this.price,
  });

  // Add the missing copyWith method
  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? imageUrl,
    String? variant,
    int? quantity,
    double? price,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  @override
  List<Object> get props => [id, productId, name, imageUrl, variant, quantity, price];
}