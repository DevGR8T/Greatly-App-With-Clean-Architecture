import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:greatly_user/features/cart/domain/entities/cart_item.dart';
import 'package:greatly_user/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:greatly_user/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:greatly_user/features/reviews/presentation/pages/review_page.dart';
import 'package:greatly_user/features/reviews/presentation/widgets/rating_stars.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/strings.dart';
import '../../../../shared/components/error_state.dart';
import '../../../../shared/components/app_shimmer.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';

/// Displays detailed information about a specific product.
class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  String? _selectedSize;
  final List<String> availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        print('Creating ProductBloc with ID: ${widget.productId}');
        return getIt<ProductBloc>()..add(GetProductById(id: widget.productId));
      },
      child: Scaffold(
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () {
                  print(
                      'Retrying to fetch product with ID: ${widget.productId}');
                  context
                      .read<ProductBloc>()
                      .add(GetProductById(id: widget.productId));
                },
              );
            }

            if (state is ProductLoaded && state.selectedProduct != null) {
              final product = state.selectedProduct!;
              return CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  _buildProductImages(product),
                  _buildProductDetails(product),
                  _buildSimilarProducts(state),
                  // Add space for the bottom sheet
                  SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
        bottomSheet: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoaded && state.selectedProduct != null) {
              return _buildBottomActions(state.selectedProduct!);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      leading: IconButton(
          icon: Icon(Platform.isIOS
              ? Icons.arrow_back_ios
              : Icons.arrow_back), // Use iOS-specific icon),
          onPressed: () {
            Navigator.of(context).pop();
            FocusScope.of(context).unfocus();
          }),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to wishlist'),backgroundColor: AppColors.success,duration: Duration(seconds: 1),),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share functionality coming soon')),
            );
          },
        ),
      ],
    );
  }

  /// Builds the product image carousel with thumbnails like in the first image
  /// Builds the product image carousel with thumbnails
  Widget _buildProductImages(Product product) {
    final List<String> images = product.images.isNotEmpty
        ? product.images
        : [product.imageUrl]; // Fallback to imageUrl if images array is empty

    print('Images: $images');

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Main image display
          SizedBox(
            height: 250,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: images[_selectedImageIndex].startsWith('http')
                  ? images[_selectedImageIndex]
                  : '${Strings.imageBaseUrl}${images[_selectedImageIndex]}',
              fit: BoxFit.contain,
              placeholder: (context, url) => AppShimmer(
                child: Container(color: Colors.white),
              ),
              errorWidget: (context, url, error) {
                print("Error loading image: $url - $error");
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey[400], size: 50),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Thumbnail row - now we check if there are more than 1 unique images
          if (images.length > 1)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: _selectedImageIndex == index
                            ? Border.all(color: AppColors.primary, width: 2)
                            : Border.all(color: Colors.grey[300]!, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: CachedNetworkImage(
                          imageUrl: images[index].startsWith('http')
                              ? images[index]
                              : '${Strings.imageBaseUrl}${images[index]}',
                          fit: BoxFit.fill,
                          placeholder: (context, url) => AppShimmer(
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (context, url, error) {
                            print("Error loading thumbnail: $url - $error");
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the product details section
  Widget _buildProductDetails(Product product) {
    final bool isFashionCategory =
        product.category.name.toLowerCase().contains('fashion') ||
            product.category.name.toLowerCase().contains('clothes') ||
            product.category.name.toLowerCase().contains('apparel');

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Text(
              product.category.name,
              style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // Product Name
            Text(
              product.name,
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Rating
            _buildRating(product),
            const SizedBox(height: 16),

            // Price
            _buildPrice(product),
            const SizedBox(height: 24),

            // Size selector for fashion items
            if (isFashionCategory) _buildSizeSelector(),
            if (isFashionCategory) const SizedBox(height: 24),

            // Quantity selector
            _buildQuantitySelector(product),
            const SizedBox(height: 24),

            // Description
            _buildDescription(product),
            const SizedBox(height: 24),

            // Specifications
            if (product.specifications.isNotEmpty)
              _buildSpecifications(product),
          ],
        ),
      ),
    );
  }

  /// Builds the size selector for fashion products
  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Size',
          style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableSizes.map((size) {
            final bool isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  size,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds the product rating section
  Widget _buildRating(Product product) {
    return BlocProvider(
      create: (context) =>
          getIt<ReviewBloc>()..add(FetchProductReviews(productId: product.id)),
      child: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          // Default values from product entity (fallback)
          double displayRating = product.rating;
          int displayReviewCount = product.reviewCount;

          // If we have loaded review data, use that instead
          if (state is ReviewsLoaded) {
            displayRating = state.averageRating;
            displayReviewCount = state.reviews.length;
          }

          return Row(
            children: [
              Row(
                children: [
                  RatingStars(
                    rating: displayRating,
                    size: 20,
                    showRatingText: true,
                    reviewCount: displayReviewCount,
                    ratingTextStyle: AppTextStyles.bodyText2
                        .copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Navigate to reviews page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewPage(
                        productId: product.id,
                        productName: product.name,
                      ),
                    ),
                  );
                },
                child: Text(
                  'See more >',
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the product price section
  Widget _buildPrice(Product product) {
    return Row(
      children: [
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: AppTextStyles.headline6.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        if (product.discount > 0) ...[
          Text(
            '\$${product.originalPrice.toStringAsFixed(2)}',
            style: AppTextStyles.bodyText1.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${product.discount}% OFF',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the quantity selector and stock information
  Widget _buildQuantitySelector(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quantity',
          style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: AppTextStyles.subtitle1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'In Stock: ${product.stockQuantity}',
              style: AppTextStyles.bodyText2.copyWith(
                color: product.stockQuantity > 10
                    ? Colors.green
                    : product.stockQuantity > 0
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the product description section
  Widget _buildDescription(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: AppTextStyles.bodyText2,
        ),
      ],
    );
  }

  /// Builds the product specifications section
  Widget _buildSpecifications(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...product.specifications.entries.map(
          (spec) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    spec.key,
                    style: AppTextStyles.bodyText2.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    spec.value,
                    style: AppTextStyles.bodyText2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the "You May Also Like" section with similar products
  Widget _buildSimilarProducts(ProductLoaded state) {
    // Find products in the same category
    final similarProducts = state.products
        .where((product) =>
            product.id != state.selectedProduct!.id &&
            product.category.id == state.selectedProduct!.category.id)
        .take(4)
        .toList();

    if (similarProducts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'You May Also Like',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 280, // Set an appropriate height for your product cards
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: similarProducts.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 170, // Set an appropriate width for your product cards
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ProductCard(
                      product: similarProducts[index],
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(
                              productId: similarProducts[index].id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom action buttons for wishlist and cart
  Widget _buildBottomActions(Product product) {
    final bool isFashionCategory =
        product.category.name.toLowerCase().contains('fashion') ||
            product.category.name.toLowerCase().contains('clothes') ||
            product.category.name.toLowerCase().contains('apparel');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.favorite_border),
              label: const Text('Wishlist'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: AppColors.primary),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to wishlist'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: const Icon(
                Icons.shopping_cart,
                color: AppColors.background,
              ),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // Check if size is selected for fashion items
                if (isFashionCategory && _selectedSize == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a size',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      duration: Duration(seconds: 1),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Create a cart item from the product
                final CartItem cartItem = CartItem(
                  id: product
                      .id, // Use product.id as the item.id for consistency
                  productId: product.id,
                  name: product.name,
                  price: product.price,
                  quantity: _quantity,
                  imageUrl: product.imageUrl,
                  variant: isFashionCategory && _selectedSize != null
                      ? _selectedSize!
                      : '',
                );

                // Dispatch AddToCartEvent to CartBloc
                BlocProvider.of<CartBloc>(context)
                    .add(AddToCartEvent(cartItem: cartItem));

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'product Added to cart',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
