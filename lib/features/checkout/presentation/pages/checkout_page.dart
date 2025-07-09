import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/theme/app_colors.dart';
import 'package:greatly_user/features/checkout/presentation/pages/order_confirmation_page.dart';

import '../../data/models/cart_item_model.dart';
import '../../domain/entities/address.dart' as app_entities;
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/payment_method.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import '../widgets/address_selection_widget.dart';
import '../widgets/check_out_progress_indicator.dart'; 
import '../widgets/checkout_summary_widget.dart';
import '../widgets/order_confirmation_widget.dart';
import '../widgets/payment_method_selection_widget.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  final _couponController = TextEditingController();

  app_entities.Address? _selectedShippingAddress;
  app_entities.Address? _selectedBillingAddress;
  bool _isLoading = false;
  List<app_entities.Address> _addresses = [];
  bool _sameAsBillingAddress = true;
  PaymentMethod? _selectedPaymentMethod;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    // Load saved addresses and payment methods when the page initializes
    context.read<CheckoutBloc>().add(LoadSavedAddresses());
    context.read<CheckoutBloc>().add(LoadSavedPaymentMethods());
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _handleAddressAdded(app_entities.Address address) {
    setState(() {
      // Add the new address to the list immediately
      _addresses.add(address);
      // If it's the first address or marked as default, select it
      if (_selectedShippingAddress == null || address.isDefault) {
        _selectedShippingAddress = address;
      }
      _isLoading = false;
    });
  }

  void _createOrder() {
    if (_selectedShippingAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping address')),
      );
      return;
    }

    if (!_sameAsBillingAddress && _selectedBillingAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a billing address')),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    // Convert cart items to the format expected by the repository
    final cartItemsMap = widget.cartItems
        .map((item) => CartItemModel.fromEntity(item).toJson())
        .toList();

    context.read<CheckoutBloc>().add(
          CreateOrderEvent(
            cartItems: cartItemsMap,
            shippingAddress: _selectedShippingAddress!,
            billingAddress: _sameAsBillingAddress
                ? _selectedShippingAddress
                : _selectedBillingAddress,
            selectedPaymentMethodId: _selectedPaymentMethod!.id.toString(),
            couponCode: _couponController.text.isNotEmpty
                ? _couponController.text
                : null,
          ),
        );
  }

  void _initializePayment(String orderId) {
    context.read<CheckoutBloc>().add(
          InitializePaymentEvent(
            orderId: orderId,
            paymentMethodId: _selectedPaymentMethod!.id.toString(),
          ),
        );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      // Validate current step before proceeding
      if (_currentStep == 0 && _selectedShippingAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select or add a shipping address'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      if (_currentStep == 1 && _selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a payment method'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }

      setState(() {
        _currentStep += 1;
      });

      // Refresh data when navigating forward to next steps
      if (_currentStep == 1) {
        // Refresh payment methods when going to payment method selection step
        context.read<CheckoutBloc>().add(LoadSavedPaymentMethods());
      } else if (_currentStep == 2) {
        // Refresh both addresses and payment methods for the summary step
        context.read<CheckoutBloc>().add(LoadSavedAddresses());
        context.read<CheckoutBloc>().add(LoadSavedPaymentMethods());
      }
    } else {
      // Final step - create order
      _createOrder();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });

      // Refresh data when navigating back to previous steps
      if (_currentStep == 0) {
        // Refresh addresses when going back to address selection step
        context.read<CheckoutBloc>().add(LoadSavedAddresses());
      } else if (_currentStep == 1) {
        // Refresh payment methods when going back to payment method selection step
        context.read<CheckoutBloc>().add(LoadSavedPaymentMethods());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          elevation: 0,
        ),
        body: // Replace your existing BlocConsumer listener with this fixed version
            BlocConsumer<CheckoutBloc, CheckoutState>(
          listener: (context, state) {


            if (state is OrderCreationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    duration: Duration(seconds: 1)),
              );
            } else if (state is OrderCreated) {
              _orderId = state.order.id;
              _initializePayment(state.order.id!);
            } else if (state is PaymentInitializationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    duration: Duration(seconds: 1)),
              );
            } else if (state is PaymentInitialized) {
              context.read<CheckoutBloc>().add(
                    ProcessStripePayment(state.order),
                  );
            } else if (state is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    duration: Duration(seconds: 1)),
              );
            } else if (state is PaymentConfirmed) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => OrderConfirmationPage(orderId: state.orderId),
                ),
              );
            } else if (state is AddressSaving) {
              setState(() {
                _isLoading = true;
              });
            } else if (state is AddressSaveSuccess) {
              setState(() {
                _isLoading = false;
              });
            } else if (state is AddressesLoaded) {


              for (var addr in state.addresses) {

              }

              setState(() {
                _addresses = state.addresses;
                _isLoading = false;

                // If there are no addresses, clear selection
                if (state.addresses.isEmpty) {
                  _selectedShippingAddress = null;
                  _selectedBillingAddress = null;
                } else {
                  // If selection is now invalid, pick default or first
                  bool exists = _selectedShippingAddress != null &&
                      state.addresses.any(
                          (addr) => addr.id == _selectedShippingAddress!.id);
                  if (!exists) {
                    _selectedShippingAddress = state.addresses.firstWhere(
                      (address) => address.isDefault,
                      orElse: () => state.addresses.first,
                    );
                  }
                }
              });
            } else if (state is AddressesError) {

              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('Failed to load addresses: ${state.message}')),
              );
            } else if (state is AddressesLoading) {

              setState(() {
                _isLoading = true;
              });
            } else if (state is AddressDeleted) {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address deleted successfully'),
                   backgroundColor: AppColors.error,
                ),
              );
            } else if (state is AddressDeletionError) {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error deleting address: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  CheckoutProgressIndicator(currentStep: _currentStep),

                  // Main content
                  Expanded(
                    child: _buildCurrentStep(context, state),
                  ),

                  // Bottom navigation
                  if (state is! CheckoutLoading &&
                      state is! PaymentInProgress &&
                      state is! PaymentConfirmed &&
                      state is! OrderCancelled)
                    _buildBottomNavigation(),
                ],
              ),
            );
          },
        ));
  }

  Widget _buildCurrentStep(BuildContext context, CheckoutState state) {
    if (state is CheckoutLoading || state is PaymentInProgress) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    switch (_currentStep) {
      case 0:
        return AddressSelectionWidget(
          key: ValueKey(_addresses.length),
          isLoading: _isLoading,
          addresses: _addresses,
          selectedShippingAddress: _selectedShippingAddress,
          selectedBillingAddress: _selectedBillingAddress,
          sameAsBillingAddress: _sameAsBillingAddress,
          onShippingAddressSelected: (address) {
            setState(() {
              _selectedShippingAddress = address;
            });
          },
          onBillingAddressSelected: (address) {
            setState(() {
              _selectedBillingAddress = address;
            });
          },
          onSameAsBillingChanged: (value) {
            setState(() {
              _sameAsBillingAddress = value;
            });
          },
          onAddressAdded: _handleAddressAdded,
        );
      case 1:
        return PaymentMethodSelectionWidget(
          isLoading: state is PaymentMethodsLoading,
          paymentMethods:
              state is PaymentMethodsLoaded ? state.paymentMethods : [],
          selectedPaymentMethod: _selectedPaymentMethod,
          onPaymentMethodSelected: (method) {
            setState(() {
              _selectedPaymentMethod = method;
            });
          },
          onPaymentMethodAdded: () {
            // Reload payment methods after adding new one
            context.read<CheckoutBloc>().add(LoadSavedPaymentMethods());
          },
        );
      case 2:
        return CheckoutSummaryWidget(
          cartItems: widget.cartItems,
          shippingAddress: _selectedShippingAddress,
          billingAddress: _sameAsBillingAddress
              ? _selectedShippingAddress
              : _selectedBillingAddress,
          paymentMethod: _selectedPaymentMethod,
          couponController: _couponController,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: Row(
                children: const [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 8),
                  Text('Back'),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Row(
              children: [
                Text(_currentStep < 2 ? 'Continue' : 'Place Order'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
