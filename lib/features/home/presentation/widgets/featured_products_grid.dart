import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greatly_user/core/constants/strings.dart';
import '../../domain/entities/featured_product.dart';
import '../../../../shared/components/app_shimmer.dart';

/// A widget that displays a grid of featured products.
class FeaturedProductsGrid extends StatelessWidget {
  /// List of featured products to display in the grid.
  final List<FeaturedProduct> products;

  /// Constructor for the `FeaturedProductsGrid` widget.
  /// 
  /// [products] is the list of featured products to be displayed.
  const FeaturedProductsGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.all(16), // Padding around the grid
        shrinkWrap: false, // Allow the grid to take available space
        physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling for the grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          childAspectRatio: 1, // Aspect ratio of each grid item
          crossAxisSpacing: 16, // Horizontal spacing between grid items
          mainAxisSpacing: 16, // Vertical spacing between grid items
        ),
        itemCount: products.length, // Number of items in the grid
        itemBuilder: (context, index) {
          final product = products[index]; // Current product
          
          // Debug print to help diagnose image URL issues
          print("Product: ${product.name}, Image URL: ${Strings.imageBaseUrl}${product.imageUrl}");
          
          return Card(
            elevation: 2, // Elevation for the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners for the card
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
              children: [
                // Displays the product image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)), // Rounded corners for the image
                  child: AspectRatio(
                    aspectRatio: 1.7, // Ensures the image is square
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: '${Strings.imageBaseUrl}${product.imageUrl}', // Full URL for the product image
                            fit: BoxFit.fill, // Ensures the image covers the available space
                            placeholder: (context, url) => AppShimmer(
                              child: Container(
                                color: Colors.white, // Placeholder background color
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              // Debug print for error tracking
                              print("Error loading image: $url - $error");
                              return Image.asset(
                                'lib/resources/assets/images/placeholder.png', // Fallback image if loading fails
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300], // Background color for missing images
                            child: const Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey), // Icon for missing images
                            ),
                          ),
                  ),
                ),
                // Displays the product name and price
                Padding(
                  padding: const EdgeInsets.all(8.0), // Padding around the text
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1, // Limit to one line
                        overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                      ),
                      const SizedBox(height: 4), // Spacing between name and price
                      // Product price
                      Text(
                        '\$${product.price.toStringAsFixed(2)}', // Format price to 2 decimal places
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
  }
}