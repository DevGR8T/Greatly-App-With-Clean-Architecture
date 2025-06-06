import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  /// Gets the current cart
  Future<Either<Failure, Cart>> getCart();

  /// Adds an item to the cart
  Future<Either<Failure, Cart>> addToCart(CartItem item);

  /// Updates an existing cart item
  Future<Either<Failure, Cart>> updateCartItem(CartItem item);

  /// Removes an item from the cart
  Future<Either<Failure, Cart>> removeFromCart(String productId);

  /// Clears all items from the cart
  Future<Either<Failure, Cart>> clearCart();

  /// Synchronizes offline cart actions with remote server
  Future<Either<Failure, Cart>> syncOfflineCartActions();
}
