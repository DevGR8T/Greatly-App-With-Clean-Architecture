import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repository/cart_repository.dart';
import '../datasources/local/cart_local_data_source.dart';
import '../datasources/remote/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Cart>> getCart() async {
    // First check if we can get data from local storage
    try {
      final localCart = await localDataSource.getCart();
      
      // If online, fetch from remote and update local cache
      if (await networkInfo.isConnected) {
        try {
          final remoteCart = await remoteDataSource.getCart();
          await localDataSource.saveCart(remoteCart);
          return Right(remoteCart);
        } on ServerException catch (e) {
          // On server error, return the local data with warning

          return Right(localCart);
        }
      } else {
        // If offline, just use the local data
        return Right(localCart);
      }
    } on CacheException catch (e) {
      // If no local data and offline, return cache failure
      if (!(await networkInfo.isConnected)) {
        return Left(CacheFailure(e.message));
      }
      
      // If no local data but online, try to get from remote
      try {
        final remoteCart = await remoteDataSource.getCart();
        await localDataSource.saveCart(remoteCart);
        return Right(remoteCart);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Cart>> addToCart(CartItem item) async {
    final cartItemModel = CartItemModel.fromEntity(item);
    
    // Add to local cache first for better UX (optimistic update)
    try {
      // Get current cart
      final currentCart = await localDataSource.getCart();
      
      // Add or update item in cart
      final existingItemIndex = currentCart.items.indexWhere(
        (i) => i.productId == item.productId && i.variant == item.variant,
      );
      
      final updatedItems = [...currentCart.items];
      
      if (existingItemIndex >= 0) {
        // Update existing item
        final existingItem = currentCart.items[existingItemIndex];
        final updatedItem = CartItemModel(
          id: existingItem.id,
          productId: existingItem.productId,
          name: existingItem.name,
          imageUrl: existingItem.imageUrl,
          variant: existingItem.variant,
          quantity: existingItem.quantity + cartItemModel.quantity,
          price: cartItemModel.price,
        );
        updatedItems[existingItemIndex] = updatedItem;
      } else {
        // Add new item
        updatedItems.add(cartItemModel);
      }
      
      // Calculate new total price
      final newTotalPrice = updatedItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      
      // Create updated cart
      final updatedCart = CartModel(
        id: currentCart.id,
        items: updatedItems,
        totalPrice: newTotalPrice,
      );
      
      // Save to local storage
      await localDataSource.saveCart(updatedCart);
      
      // If online, sync with server
      if (await networkInfo.isConnected) {
        try {
          final serverCart = await remoteDataSource.addToCart(cartItemModel);
          await localDataSource.saveCart(serverCart);
          return Right(serverCart);
        } on ServerException catch (e) {
          // Queue action for later sync
          await localDataSource.queueAction(
            CartAction(type: CartActionType.add, item: cartItemModel),
          );
          // Return the locally updated cart even on server error
          return Right(updatedCart);
        }
      } else {
        // Queue this action for later sync
        await localDataSource.queueAction(
          CartAction(type: CartActionType.add, item: cartItemModel),
        );
        return Right(updatedCart);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Cart>> updateCartItem(CartItem item) async {
    final cartItemModel = CartItemModel.fromEntity(item);
    
    // Update local cache first for better UX (optimistic update)
    try {
      // Get current cart
      final currentCart = await localDataSource.getCart();
      
      // Update item in cart
      final existingItemIndex = currentCart.items.indexWhere(
        (i) => i.id == item.id,
      );
      
      if (existingItemIndex < 0) {
        return Left(CacheFailure('Item not found in cart'));
      }
      
      final updatedItems = [...currentCart.items];
      updatedItems[existingItemIndex] = cartItemModel;
      
      // Calculate new total price
      final newTotalPrice = updatedItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      
      // Create updated cart
      final updatedCart = CartModel(
        id: currentCart.id,
        items: updatedItems,
        totalPrice: newTotalPrice,
      );
      
      // Save to local storage
      await localDataSource.saveCart(updatedCart);
      
      // If online, sync with server
      if (await networkInfo.isConnected) {
        try {
          final serverCart = await remoteDataSource.updateCartItem(cartItemModel);
          await localDataSource.saveCart(serverCart);
          return Right(serverCart);
        } on ServerException catch (e) {
          // Queue action for later sync
          await localDataSource.queueAction(
            CartAction(type: CartActionType.update, item: cartItemModel),
          );
          // Return the locally updated cart even on server error
          return Right(updatedCart);
        }
      } else {
        // Queue this action for later sync
        await localDataSource.queueAction(
          CartAction(type: CartActionType.update, item: cartItemModel),
        );
        return Right(updatedCart);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(String itemId) async {
    // Update local cache first for better UX (optimistic update)
    try {
      // Get current cart
      final currentCart = await localDataSource.getCart();
      
      // Remove item from cart
      final updatedItems = currentCart.items
          .where((item) => item.id != itemId)
          .toList();
      
      // Calculate new total price
      final newTotalPrice = updatedItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      
      // Create updated cart
      final updatedCart = CartModel(
        id: currentCart.id,
        items: updatedItems,
        totalPrice: newTotalPrice,
      );
      
      // Save to local storage
      await localDataSource.saveCart(updatedCart);
      
      // If online, sync with server
      if (await networkInfo.isConnected) {
        try {
          final serverCart = await remoteDataSource.removeFromCart(itemId);
          await localDataSource.saveCart(serverCart);
          return Right(serverCart);
        } on ServerException catch (e) {
          // Queue action for later sync
          await localDataSource.queueAction(
            CartAction(type: CartActionType.remove, itemId: itemId),
          );
          // Return the locally updated cart even on server error
          return Right(updatedCart);
        }
      } else {
        // Queue this action for later sync
        await localDataSource.queueAction(
          CartAction(type: CartActionType.remove, itemId: itemId),
        );
        return Right(updatedCart);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart() async {
    // Update local cache first for better UX (optimistic update)
    try {
      // Create empty cart
      final emptyCart = CartModel.empty();
      
      // Save to local storage
      await localDataSource.saveCart(emptyCart);
      
      // If online, sync with server
      if (await networkInfo.isConnected) {
        try {
          final serverCart = await remoteDataSource.clearCart();
          await localDataSource.saveCart(serverCart);
          return Right(serverCart);
        } on ServerException catch (e) {
          // Queue action for later sync
          await localDataSource.queueAction(
            CartAction(type: CartActionType.clear),
          );
          // Return the locally updated cart even on server error
          return Right(emptyCart);
        }
      } else {
        // Queue this action for later sync
        await localDataSource.queueAction(
          CartAction(type: CartActionType.clear),
        );
        return Right(emptyCart);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Cart>> syncOfflineCartActions() async {
    if (await networkInfo.isConnected) {
      try {
        // Get queued actions
        final queuedActions = await localDataSource.getQueuedActions();
        
        // If no actions, just return current cart
        if (queuedActions.isEmpty) {
          return await getCart();
        }
        
        // Process each action in order
        try {
          CartModel currentCart = await remoteDataSource.getCart();
          
          for (final action in queuedActions) {
            try {
              switch (action.type) {
                case CartActionType.add:
                  if (action.item != null) {
                    currentCart = await remoteDataSource.addToCart(action.item!);
                  }
                  break;
                case CartActionType.update:
                  if (action.item != null) {
                    currentCart = await remoteDataSource.updateCartItem(action.item!);
                  }
                  break;
                case CartActionType.remove:
                  if (action.itemId != null) {
                    currentCart = await remoteDataSource.removeFromCart(action.itemId!);
                  }
                  break;
                case CartActionType.clear:
                  currentCart = await remoteDataSource.clearCart();
                  break;
              }
            } catch (e) {
              // Continue processing other actions even if one fails

            }
          }
          
          // Clear action queue
          await localDataSource.clearQueuedActions();
          
          // Save the latest cart locally
          await localDataSource.saveCart(currentCart);
          
          return Right(currentCart);
        } catch (e) {
          // If sync fails, return current local cart
          final localCart = await localDataSource.getCart();
          return Right(localCart);
        }
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    } else {
      // If still offline, we can't sync
      return Left(ConnectionFailure('No internet connection available'));
    }
  }
}
