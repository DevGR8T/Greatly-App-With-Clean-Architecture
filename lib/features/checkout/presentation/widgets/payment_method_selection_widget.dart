import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/payment_method.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import '../pages/add_payment_method_page.dart';

class PaymentMethodSelectionWidget extends StatefulWidget {
  final bool isLoading;
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final Function(PaymentMethod) onPaymentMethodSelected;
  final VoidCallback? onPaymentMethodAdded;

  const PaymentMethodSelectionWidget({
    Key? key,
    required this.isLoading,
    required this.paymentMethods,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
    this.onPaymentMethodAdded,
  }) : super(key: key);

  @override
  State<PaymentMethodSelectionWidget> createState() =>
      _PaymentMethodSelectionWidgetState();
}

class _PaymentMethodSelectionWidgetState
    extends State<PaymentMethodSelectionWidget> {
  late List<PaymentMethod> currentPaymentMethods;
  int? deletingPaymentMethodId;

  @override
  void initState() {
    super.initState();
    currentPaymentMethods = List.from(widget.paymentMethods);
  }

 @override
void didUpdateWidget(PaymentMethodSelectionWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  
 if (deletingPaymentMethodId == null && 
      (currentPaymentMethods.isEmpty || 
       !listEquals(currentPaymentMethods.map((e) => e.id).toList(), 
                  widget.paymentMethods.map((e) => e.id).toList()))) {
    setState(() {
      currentPaymentMethods = List.from(widget.paymentMethods);
    });
  }
}

  @override
void dispose() {
  _deletionTimer?.cancel();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return BlocListener<CheckoutBloc, CheckoutState>(
  listener: (context, state) {
    print('🔍 BLoC State: ${state.runtimeType}');
    
    if (state is PaymentMethodDeleted) {
      print('✅ Payment method deleted successfully');
      
      // Cancel timeout timer
      _deletionTimer?.cancel();
      
      if (deletingPaymentMethodId != null) {
        setState(() {
            currentPaymentMethods = List.from(widget.paymentMethods);
        // Clear deleting state when fresh data arrives
        if (deletingPaymentMethodId != null) {
          deletingPaymentMethodId = null;
        }
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method deleted'), 
            backgroundColor: Colors.green
          ),
        );
      }
      
      // Local state already updated above
      
    } else if (state is PaymentMethodDeletionError) {
      print('❌ Payment method deletion error: ${state.message}');
      
      // Cancel timeout timer
      _deletionTimer?.cancel();
      
      setState(() {
        deletingPaymentMethodId = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.message}'), 
            backgroundColor: Colors.red
          ),
        );
      }
      
    } else if (state is PaymentMethodsLoaded) {
      print('📋 Payment methods loaded: ${state.paymentMethods.length} items');
      
      // Only update if not currently deleting
      if (deletingPaymentMethodId == null) {
        setState(() {
          currentPaymentMethods = List.from(state.paymentMethods);
        });
      }
    }
  },
  
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (currentPaymentMethods.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No saved payment methods found. Please add a payment method.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              _buildPaymentMethodsList(),
            const SizedBox(height: 24),
            _buildAddNewPaymentMethodButton(context),
          ],
        ),
      ),
    );
  }

 

  Widget _buildPaymentMethodsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentPaymentMethods.length,
      itemBuilder: (context, index) {
        final paymentMethod = currentPaymentMethods[index];
        final isSelected = widget.selectedPaymentMethod?.id == paymentMethod.id;
        final isDeleting = deletingPaymentMethodId == paymentMethod.id;

        return Opacity(
          opacity: isDeleting ? 0.5 : 1.0,
          child: Card(
            elevation: isSelected ? 2 : 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: isDeleting
                  ? null
                  : () => widget.onPaymentMethodSelected(paymentMethod),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Radio<int>(
                      value: paymentMethod.id,
                      groupValue: widget.selectedPaymentMethod?.id,
                      onChanged: isDeleting
                          ? null
                          : (_) =>
                              widget.onPaymentMethodSelected(paymentMethod),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    _buildPaymentTypeIcon(
                        paymentMethod.type, paymentMethod.cardBrand),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPaymentMethodDisplayName(paymentMethod),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '•••• ${paymentMethod.lastFour}',
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          if (paymentMethod.expiryDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Expires ${paymentMethod.expiryDate}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          if (paymentMethod.isDefault)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isDeleting)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, paymentMethod);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

void _showDeleteConfirmationDialog(
    BuildContext context, PaymentMethod paymentMethod) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      title: const Text('Delete Payment Method'),
      content: Text(
          'Are you sure you want to delete this ${_getPaymentMethodDisplayName(paymentMethod)}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _deletePaymentMethodWithTimeout(paymentMethod);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
          ),
          child: const Text('DELETE'),
        ),
      ],
    ),
  );
}



Timer? _deletionTimer;

void _deletePaymentMethodWithTimeout(PaymentMethod paymentMethod) {
  // Cancel any existing timer
  _deletionTimer?.cancel();
  
  setState(() {
    deletingPaymentMethodId = paymentMethod.id;
  });

  // Set timeout to reset state if stuck
  _deletionTimer = Timer(const Duration(seconds: 10), () {
    if (mounted && deletingPaymentMethodId == paymentMethod.id) {
      setState(() {
        deletingPaymentMethodId = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request timed out. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  });

  context.read<CheckoutBloc>().add(
    DeletePaymentMethodEvent(paymentMethodId: paymentMethod.id),
  );
}


  String _getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method.type) {
      case PaymentType.creditCard:
        return method.cardBrand ?? 'Credit Card';
      case PaymentType.paypal:
        return 'PayPal';
      case PaymentType.applePay:
        return 'Apple Pay';
      case PaymentType.googlePay:
        return 'Google Pay';
    }
  }

  Widget _buildPaymentTypeIcon(PaymentType type, String? cardBrand) {
    if (type == PaymentType.creditCard && cardBrand != null) {
      return _buildCardBrandLogo(cardBrand);
    }

    IconData iconData;
    Color iconColor;

    switch (type) {
      case PaymentType.paypal:
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.blue.shade800;
        break;
      case PaymentType.applePay:
        iconData = Icons.apple;
        iconColor = Colors.black;
        break;
      case PaymentType.googlePay:
        iconData = Icons.g_mobiledata;
        iconColor = Colors.green.shade700;
        break;
      case PaymentType.creditCard:
        if (cardBrand != null) {
          switch (cardBrand.toLowerCase()) {
            case 'visa':
              iconData = Icons.credit_card;
              iconColor = Colors.blue.shade800;
              break;
            case 'mastercard':
              iconData = Icons.credit_card;
              iconColor = Colors.deepOrange;
              break;
            case 'amex':
            case 'american express':
              iconData = Icons.credit_card;
              iconColor = Colors.blue;
              break;
            case 'discover':
              iconData = Icons.credit_card;
              iconColor = Colors.orange;
              break;
            default:
              iconData = Icons.credit_card;
              iconColor = Colors.grey.shade700;
          }
        } else {
          iconData = Icons.credit_card;
          iconColor = Colors.grey.shade700;
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 28,
      ),
    );
  }

  Widget _buildCardBrandLogo(String cardBrand) {
    String? assetPath;

    switch (cardBrand.toLowerCase()) {
      case 'visa':
        assetPath = 'assets/images/visa_logo.png';
        break;
      case 'mastercard':
        assetPath = 'assets/images/Mastercard-logo-black.png';
        break;
      case 'amex':
      case 'american express':
        assetPath = 'assets/images/amex_logo.png';
        break;
      case 'discover':
        assetPath = 'assets/images/discover_logo.png';
        break;
    }

    if (assetPath != null) {
      return Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.credit_card,
        color: Colors.grey.shade700,
        size: 28,
      ),
    );
  }

  Widget _buildAddNewPaymentMethodButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddPaymentMethodScreen(),
          ),
        );

        if (widget.onPaymentMethodAdded != null) {
          widget.onPaymentMethodAdded!();
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('Add New Payment Method'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

}
