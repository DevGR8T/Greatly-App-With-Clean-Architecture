import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/syncofflineaction_usecase.dart';
import '../../domain/usecases/update_cart_usecase.dart';

part 'cart_event.dart';
part 'cart_state.dart';

@injectable
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final UpdateCartItemUseCase _updateCartItemUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final SyncOfflineCartActionsUseCase _syncOfflineCartActionsUseCase;

  CartBloc({
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required UpdateCartItemUseCase updateCartItemUseCase,
    required ClearCartUseCase clearCartUseCase,
    required SyncOfflineCartActionsUseCase syncOfflineCartActionsUseCase,
  })  : _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _removeFromCartUseCase = removeFromCartUseCase,
        _updateCartItemUseCase = updateCartItemUseCase,
        _clearCartUseCase = clearCartUseCase,
        _syncOfflineCartActionsUseCase = syncOfflineCartActionsUseCase,
        super(CartInitial()) {
    on<GetCartEvent>(_onGetCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<ClearCartEvent>(_onClearCart);
    on<SyncOfflineCartActionsEvent>(_onSyncOfflineCartActions);
  }

  FutureOr<void> _onGetCart(GetCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await _getCartUseCase(NoParams());
    _emitResult(result, emit);
  }

  FutureOr<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await _addToCartUseCase(AddToCartParams(item: event.cartItem));
    _emitResult(result, emit);
  }

  FutureOr<void> _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await _removeFromCartUseCase(RemoveFromCartParams(productId: event.cartItemId));
    _emitResult(result, emit);
  }

  FutureOr<void> _onUpdateCartItem(UpdateCartItemEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await _updateCartItemUseCase(UpdateCartItemParams(item: event.cartItem));
    _emitResult(result, emit);
  }

  FutureOr<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await _clearCartUseCase(NoParams());
    _emitResult(result, emit);
  }

  FutureOr<void> _onSyncOfflineCartActions(
      SyncOfflineCartActionsEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final result = await _syncOfflineCartActionsUseCase(NoParams());
    _emitResult(result, emit);
  }

  void _emitResult(Either<Failure, Cart> result, Emitter<CartState> emit) {
    emit(result.fold(
      (failure) => CartError(message: _mapFailureToMessage(failure)),
      (cart) => cart.items.isEmpty
          ? CartEmpty()
          : CartLoaded(cart: cart),
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case ConnectionFailure:
        return 'No internet connection. Please check your connection and try again.';
      case CacheFailure:
        return 'Cache error occurred. Please restart the app.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}


