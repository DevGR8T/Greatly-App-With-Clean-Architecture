import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greatly_user/core/constants/strings.dart';
import '../../domain/entities/featured_product.dart';
import '../../../../shared/components/app_shimmer.dart';

/// Displays a grid of featured products.
class FeaturedProductsGrid extends StatelessWidget {
  final List<FeaturedProduct> products;
  final Function(String productId) onProductSelected;

  const FeaturedProductsGrid({
    super.key,
    required this.products,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => onProductSelected(product.id.toString()), // Trigger navigation with product ID
          child: _buildProductCard(product),
        );
      },
    );
  }

  /// Builds a card for a single product.
  Widget _buildProductCard(FeaturedProduct product) {
    return Card(
      elevation: 0.1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(product),
          _buildProductDetails(product),
        ],
      ),
    );
  }

  /// Builds the product image.
  Widget _buildProductImage(FeaturedProduct product) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      child: AspectRatio(
        aspectRatio: 1.7,
        child: product.imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: '${Strings.imageBaseUrl}${product.imageUrl}',
                fit: BoxFit.contain,
                placeholder: (context, url) => AppShimmer(
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) {
                  return Image.asset(
                    'lib/resources/assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  );
                },
              )
            : Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
      ),
    );
  }

  /// Builds the product details (name and price).
  Widget _buildProductDetails(FeaturedProduct product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductName(product),
          const SizedBox(height: 4),
          _buildProductPrice(product),
        ],
      ),
    );
  }

  /// Builds the product name.
  Widget _buildProductName(FeaturedProduct product) {
    return Text(
      product.name,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the product price.
  Widget _buildProductPrice(FeaturedProduct product) {
    return Text(
      '\$${product.price.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}