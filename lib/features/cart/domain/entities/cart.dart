import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final String id;
  final List<CartItem> items;
  final double totalPrice;

  const Cart({
    required this.id,
    required this.items,
    required this.totalPrice,
  });

 
  double get subtotal => items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  
  double get total => totalPrice;
  
  // Add a copyWith method for easier modification
  Cart copyWith({
    String? id,
    List<CartItem>? items,
    double? totalPrice,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object> get props => [id, items, totalPrice];
}