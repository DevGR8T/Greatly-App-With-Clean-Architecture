import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String? imageUrl;
  final List<String>? selectedOptions; // e.g. size, color, etc.

  const CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.selectedOptions,
  });

  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [
        id,
        productId,
        title,
        price,
        quantity,
        imageUrl,
        selectedOptions,
      ];
}
