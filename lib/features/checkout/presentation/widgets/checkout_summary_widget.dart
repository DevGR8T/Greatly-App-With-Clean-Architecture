import 'package:flutter/material.dart';
import 'package:greatly_user/core/constants/strings.dart';
import 'package:greatly_user/features/checkout/domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/payment_method.dart';

class CheckoutSummaryWidget extends StatelessWidget {
  final List<CartItem> cartItems;
  final Address? shippingAddress;
  final Address? billingAddress;
  final PaymentMethod? paymentMethod;
  final TextEditingController couponController;

  const CheckoutSummaryWidget({
    Key? key,
    required this.cartItems,
    required this.shippingAddress,
    required this.billingAddress,
    required this.paymentMethod,
    required this.couponController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  
    // Calculate totals
    final subtotal = cartItems.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final shipping = 5.99; // Example shipping cost
    final tax = subtotal * 0.08; // Example tax rate
    final total = subtotal + shipping + tax;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Order items
          _buildOrderItems(),
          const Divider(height: 32),
          
          // Coupon code
          _buildCouponSection(context),
          const Divider(height: 32),
          
          // Price summary
          _buildPriceSummary(subtotal, shipping, tax, total),
          const SizedBox(height: 24),
          
          // Shipping address
          _buildAddressSection(
            context,
            'Shipping Address',
            shippingAddress,
          ),
          const SizedBox(height: 24),
          
          // Billing address
          _buildAddressSection(
            context,
            'Billing Address',
            billingAddress,
          ),
          const SizedBox(height: 24),
          
          // Payment method
          _buildPaymentMethodSection(context),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${cartItems.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...cartItems.map((item) => _buildOrderItem(item)),
      ],
    );
  }

  Widget _buildOrderItem(CartItem item) {
    
   // Fix #1: Properly format the image URL with base URL if needed
    String imageUrl = item.imageUrl ?? '';
    
    // Check if the URL needs the base URL prefix
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${Strings.imageBaseUrl}$imageUrl';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                    ),
                  )
                : const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.selectedOptions?.isNotEmpty ?? false)
                  Text(
                    item.selectedOptions!
                        .join(', '),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          
          // Price
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Coupon Code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: couponController,
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement coupon validation logic
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSummary(
    double subtotal,
    double shipping,
    double tax,
    double total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        _buildPriceRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
        _buildPriceRow('Tax', '\$${tax.toStringAsFixed(2)}'),
        const Divider(height: 24),
        _buildPriceRow(
          'Total',
          '\$${total.toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(
    BuildContext context,
    String title,
    Address? address,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (address == null)
          const Text('No address selected')
        else
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.streetAddress),
                  Text(
                    '${address.city}, ${address.stateProvince} ${address.postalCode}',
                  ),
                  Text(address.country),
                  if (address.isDefault) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (paymentMethod == null)
          const Text('No payment method selected')
        else
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildPaymentIcon(paymentMethod!.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPaymentType(paymentMethod!.type),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('•••• ${paymentMethod!.lastFour}'),
                        if (paymentMethod!.expiryDate != null)
                          Text(
                            'Expires ${paymentMethod!.expiryDate}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (paymentMethod!.isDefault) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentIcon(PaymentType type) {
    IconData iconData;
    
    switch (type) {
      case PaymentType.creditCard:
        iconData = Icons.credit_card;
        break;
      case PaymentType.paypal:
        iconData = Icons.account_balance_wallet;
        break;
      case PaymentType.applePay:
        iconData = Icons.apple;
        break;
      case PaymentType.googlePay:
        iconData = Icons.g_mobiledata;
        break;
    }
    
    return Icon(
      iconData,
      size: 24,
      color: Colors.grey.shade700,
    );
  }

  String _formatPaymentType(PaymentType type) {
    switch (type) {
      case PaymentType.creditCard:
        return paymentMethod?.cardBrand ?? 'Credit Card';
      case PaymentType.paypal:
        return 'PayPal';
      case PaymentType.applePay:
        return 'Apple Pay';
      case PaymentType.googlePay:
        return 'Google Pay';
    }
  }
}