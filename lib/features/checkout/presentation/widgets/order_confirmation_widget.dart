import 'package:flutter/material.dart';

class OrderConfirmationWidget extends StatelessWidget {
  final String orderId;

  const OrderConfirmationWidget({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSuccessIcon(),
            const SizedBox(height: 24),
            const Text(
              'Thank You!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your order has been placed successfully',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildOrderInfo(),
            const SizedBox(height: 36),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle,
        color: Colors.green.shade600,
        size: 70,
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow('Order ID:', orderId),
          const Divider(height: 20),
          _buildInfoRow('Date:', _getCurrentDateFormatted()),
          const Divider(height: 20),
          _buildInfoRow('Status:', 'Confirmed'),
          const Divider(height: 20),
          _buildInfoRow('Estimated Delivery:', _getEstimatedDeliveryDate()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to order details page
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'View Order Details',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // Navigate to home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text(
            'Continue Shopping',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  String _getCurrentDateFormatted() {
    final now = DateTime.now();
    return '${now.month}/${now.day}/${now.year}';
  }

  String _getEstimatedDeliveryDate() {
    final now = DateTime.now();
    final estimatedDelivery = now.add(const Duration(days: 5));
    return '${estimatedDelivery.month}/${estimatedDelivery.day}/${estimatedDelivery.year}';
  }
}