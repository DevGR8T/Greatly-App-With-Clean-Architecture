part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class GetCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final CartItem cartItem;

  const AddToCartEvent({required this.cartItem});

  @override
  List<Object> get props => [cartItem];
}

class RemoveFromCartEvent extends CartEvent {
  final String cartItemId;

  const RemoveFromCartEvent({required this.cartItemId});

  @override
  List<Object> get props => [cartItemId];
}

class UpdateCartItemEvent extends CartEvent {
  final CartItem cartItem;

  const UpdateCartItemEvent({required this.cartItem});

  @override
  List<Object> get props => [cartItem];
}

class ClearCartEvent extends CartEvent {}

class SyncOfflineCartActionsEvent extends CartEvent {}