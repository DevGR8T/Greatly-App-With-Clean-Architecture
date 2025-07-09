import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/features/cart/presentation/widgets/empty_cart.dart';
import 'package:greatly_user/features/checkout/presentation/pages/checkout_page.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/components/app_shimmer.dart';
import '../../../../shared/components/error_state.dart';
import '../../../checkout/domain/usecases/add_payment_method.dart';
import '../../../checkout/domain/usecases/create_stripe_portal_session.dart';
import '../../../checkout/domain/usecases/delete_address.dart';
import '../../../checkout/domain/usecases/delete_payment_method.dart';
import '../../../checkout/domain/usecases/save_address.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/cart_item_widget.dart';
import '../widgets/cart_summary_widget.dart';

// Import the checkout-specific CartItem and use cases
import '../../../checkout/domain/entities/cart_item.dart' as checkout;
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../../../checkout/domain/usecases/get_saved_addresses.dart';
import '../../../checkout/domain/usecases/get_saved_payment_methods.dart';
import '../../../checkout/domain/usecases/create_order.dart';
import '../../../checkout/domain/usecases/initialize_payment.dart';
import '../../../checkout/domain/usecases/confirm_payment.dart';
import '../../../checkout/domain/usecases/cancel_order.dart';
import '../../../checkout/domain/usecases/get_order_by_id.dart';
import '../../../checkout/domain/usecases/get_user_orders.dart';


class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(GetCartEvent());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Convert cart items to checkout cart items
 // Convert cart items to checkout cart items
List<checkout.CartItem> _convertToCheckoutCartItems(List<dynamic> cartItems) {
  return cartItems.map((item) {
    try {
      return checkout.CartItem(
        id: item.id,
        productId: item.productId,
        title: item.name, // Fix: Using 'name' from cart item instead of 'title'
        price: item.price,
        quantity: item.quantity,
        imageUrl: item.imageUrl,
        // Note: If the checkout.CartItem requires selectedOptions, you might need to convert 
        // from 'variant' or set it to null if not applicable
        selectedOptions: item.variant.isNotEmpty ? [item.variant] : null, // Optional conversion
      );
    } catch (e) {

      throw Exception('Failed to convert cart item: ${e.toString()}');
    }
  }).toList();
}
  void _navigateToCheckout() {
    if (_isProcessing) return;
    
    final cartState = context.read<CartBloc>().state;
    if (cartState is CartLoaded) {
      try {
        // Convert cart items to checkout cart items
        final checkoutCartItems = _convertToCheckoutCartItems(cartState.cart.items);
        
        // Navigate to checkout with the converted items and properly initialized bloc
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => CheckoutBloc(
                saveAddress: getIt<SaveAddress>(),
                getSavedAddresses: getIt<GetSavedAddresses>(),
                deleteAddress: getIt<DeleteAddress>(),
                getSavedPaymentMethods: getIt<GetSavedPaymentMethods>(),
                createOrder: getIt<CreateOrder>(),
                initializePayment: getIt<InitializePayment>(),
                confirmPayment: getIt<ConfirmPayment>(),
                cancelOrder: getIt<CancelOrder>(),
                getOrderById: getIt<GetOrderById>(),
                getUserOrders: getIt<GetUserOrders>(),
                addPaymentMethod: getIt<AddPaymentMethod>(),
                deletePaymentMethod: getIt<DeletePaymentMethod>(),
                createStripePortalSession: getIt<CreateStripePortalSession>(),
              ),
              child: CheckoutPage(cartItems: checkoutCartItems),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error preparing checkout: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to proceed to checkout. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (previous, current) => 
                current is CartLoaded != (previous is CartLoaded),
            builder: (context, state) {
              if (state is CartLoaded) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _isProcessing 
                      ? null 
                      : () => _showClearCartConfirmation(context),
                  tooltip: 'Clear cart',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listenWhen: (previous, current) {
          if (previous is CartLoaded && current is CartLoading) {
            return false;
          }
          return true;
        },
        listener: (context, state) {
          if (state is CartLoading) {
            setState(() {
              _isProcessing = true;
            });
          } else {
            setState(() {
              _isProcessing = false;
            });
          }
        },
        buildWhen: (previous, current) {
          if (previous is CartLoaded && current is CartLoading) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state is CartInitial) {
            return _buildLoadingState();
          } else if (state is CartLoaded) {
            return _buildLoadedState(state);
          } else if (state is CartEmpty) {
            return const EmptyCartWidget();
          } else if (state is CartError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<CartBloc>().add(GetCartEvent()),
            );
          } else if (state is CartLoading && !(state is CartLoaded)) {
            return _buildLoadingState();
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Placeholder count
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppShimmer(
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadedState(CartLoaded state) {
    final cart = state.cart;

    return FadeTransition(
      opacity: _animation,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CartItemWidget(
                    item: item,
                    isProcessing: _isProcessing,
                    onQuantityChanged: (quantity) {
                      if (_isProcessing) return;
                      
                      setState(() {
                        _isProcessing = true;
                      });
                      
                      if (quantity <= 0) {
                        context.read<CartBloc>().add(RemoveFromCartEvent(cartItemId: item.productId));
                      } else {
                        final updatedItem = item.copyWith(quantity: quantity);
                        context.read<CartBloc>()
                            .add(UpdateCartItemEvent(cartItem: updatedItem));
                      }
                    },
                    onRemove: () {
                      if (_isProcessing) return;
                      
                      setState(() {
                        _isProcessing = true;
                      });
                      context.read<CartBloc>().add(RemoveFromCartEvent(cartItemId: item.productId));
                    },
                  ),
                );
              },
            ),
          ),
          CartSummaryWidget(
            subtotal: cart.subtotal,
            total: cart.total,
            isProcessing: _isProcessing,
            onCheckout: _isProcessing ? null : () => _navigateToCheckout(),
          ),
        ],
      ),
    );
  }

  void _showClearCartConfirmation(BuildContext context) {
    if (_isProcessing) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isProcessing = true;
              });
              context.read<CartBloc>().add(ClearCartEvent());
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}