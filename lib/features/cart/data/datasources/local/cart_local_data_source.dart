import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../../core/error/exceptions.dart';
import '../../models/cart_model.dart';
import '../../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  /// Gets the cached [CartModel] for the current user which was saved the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<CartModel> getCart();

  /// Caches the current [CartModel] for the specific user.
  Future<void> saveCart(CartModel cart);

  /// Clears the cached cart data for the current user.
  Future<void> clearCart();
  
  /// Sets the active user ID (to be called after login)
  Future<void> setActiveUser(String userId);
  
  /// Clears the active user (to be called after logout)
  Future<void> clearActiveUser();

  /// Queues an action to be performed when the network is available.
  Future<void> queueAction(CartAction action);

  /// Gets all queued actions for the current user.
  Future<List<CartAction>> getQueuedActions();

  /// Clears all queued actions for the current user.
  Future<void> clearQueuedActions();
}

enum CartActionType {
  add,
  update,
  remove,
  clear,
}

class CartAction {
  final CartActionType type;
  final CartItemModel? item;
  final String? itemId;

  CartAction({
    required this.type,
    this.item,
    this.itemId,
  });

  factory CartAction.fromJson(Map<String, dynamic> json) {
    return CartAction(
      type: CartActionType.values[json['type']],
      item: json['item'] != null
          ? CartItemModel.fromJson(json['item'])
          : null,
      itemId: json['item_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'item': item?.toJson(),
      'item_id': itemId,
    };
  }
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  
  // Key prefixes for user-specific storage
  static const String activeUserKey = 'ACTIVE_USER';
  static const String cartKeyPrefix = 'CACHED_CART_';
  static const String queuedActionsKeyPrefix = 'QUEUED_CART_ACTIONS_';

  CartLocalDataSourceImpl({
    required this.sharedPreferences,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  /// Gets the current active user ID from SharedPreferences or Firebase
  String? _getCurrentUserId() {
    // First try to get from SharedPreferences (more reliable)
    final String? userId = sharedPreferences.getString(activeUserKey);
    
    // If not found, try to get from Firebase (fallback)
    if (userId == null || userId.isEmpty) {
      return _firebaseAuth.currentUser?.uid;
    }
    
    return userId;
  }
  
  /// Generate key for user-specific cart storage
  String _getCartKey(String? userId) {
    if (userId == null || userId.isEmpty) {
      // For anonymous user or no active user
      return '${cartKeyPrefix}anonymous';
    }
    return '$cartKeyPrefix$userId';
  }
  
  /// Generate key for user-specific queued actions storage
  String _getQueuedActionsKey(String? userId) {
    if (userId == null || userId.isEmpty) {
      // For anonymous user or no active user
      return '${queuedActionsKeyPrefix}anonymous';
    }
    return '$queuedActionsKeyPrefix$userId';
  }
  
  @override
  Future<void> setActiveUser(String userId) async {
    await sharedPreferences.setString(activeUserKey, userId);
    
    // Make sure user has a cart (create empty one if none exists)
    final cartKey = _getCartKey(userId);
    if (!sharedPreferences.containsKey(cartKey)) {
      await sharedPreferences.setString(
        cartKey,
        CartModel.empty().toJsonString(),
      );
    }
  }
  
  @override
  Future<void> clearActiveUser() async {
    await sharedPreferences.remove(activeUserKey);
  }

  @override
  Future<CartModel> getCart() async {
    final userId = _getCurrentUserId();
    final cartKey = _getCartKey(userId);
    
    final jsonString = sharedPreferences.getString(cartKey);
    if (jsonString != null) {
      return Future.value(CartModel.fromJsonString(jsonString));
    } else {
      final emptyCart = CartModel.empty();
      // Save the empty cart so it exists for next time
      await saveCart(emptyCart);
      return Future.value(emptyCart);
    }
  }

  @override
  Future<void> saveCart(CartModel cart) async {
    final userId = _getCurrentUserId();
    final cartKey = _getCartKey(userId);
    
    await sharedPreferences.setString(cartKey, cart.toJsonString());
  }

  @override
  Future<void> clearCart() async {
    final userId = _getCurrentUserId();
    final cartKey = _getCartKey(userId);
    
    await sharedPreferences.setString(
      cartKey,
      CartModel.empty().toJsonString(),
    );
  }

  @override
  Future<void> queueAction(CartAction action) async {
    final userId = _getCurrentUserId();
    final queuedActionsKey = _getQueuedActionsKey(userId);
    
    final queuedActions = await getQueuedActions();
    queuedActions.add(action);
    
    final jsonList = queuedActions.map((action) => action.toJson()).toList();
    await sharedPreferences.setString(
      queuedActionsKey,
      json.encode(jsonList),
    );
  }

  @override
  Future<List<CartAction>> getQueuedActions() async {
    final userId = _getCurrentUserId();
    final queuedActionsKey = _getQueuedActionsKey(userId);
    
    final jsonString = sharedPreferences.getString(queuedActionsKey);
    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((item) => CartAction.fromJson(item)).toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> clearQueuedActions() async {
    final userId = _getCurrentUserId();
    final queuedActionsKey = _getQueuedActionsKey(userId);
    
    await sharedPreferences.remove(queuedActionsKey);
  }
}