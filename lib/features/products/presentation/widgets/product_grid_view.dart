import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';

/// A grid view to display a list of products or a loading state.
class ProductGridView extends StatelessWidget {
  final List<Product> products; // List of products to display
  final Function(Product) onProductSelected; // Callback when a product is selected
  final bool isLoading; // Whether the grid is in a loading state
  final ScrollController? scrollController; // Scroll controller for the grid

  const ProductGridView({
    Key? key,
    required this.products,
    required this.onProductSelected,
    this.isLoading = false,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      // Debug log to show the actual product IDs
    for (var product in products) {
      print('Product in grid: ${product.id} - ${product.name}');
    }
    // Show loading grid if data is still loading
    if (isLoading) {
      return _buildLoadingGrid();
    }

    // Show a message if no products are available
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Display the grid of products
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        childAspectRatio: 0.6, // Aspect ratio of each grid item
        crossAxisSpacing: 7.0, // Horizontal spacing between items
        mainAxisSpacing: 16, // Vertical spacing between items
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => onProductSelected(product), // Handle product selection
        );
      },
    );
  }

  /// Builds a loading grid with placeholder cards.
  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        childAspectRatio: 0.7, // Aspect ratio of each grid item
        crossAxisSpacing: 16, // Horizontal spacing between items
        mainAxisSpacing: 16, // Vertical spacing between items
      ),
      itemCount: 6, // Number of placeholder items
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for product image
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                  ),
                ),
              ),
              // Placeholder for product details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        width: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 60,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}