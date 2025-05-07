import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greatly_user/core/constants/strings.dart';
import 'package:greatly_user/core/di/service_locator.dart';
import 'package:greatly_user/shared/components/app_shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_badge.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategory(),
                    const SizedBox(height: 2),
                    _buildProductName(),
                    const Spacer(),
                    _buildPriceRow(),
                    const SizedBox(height: 5),
                    _buildRatingRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
          child: AspectRatio(
            aspectRatio: 0.83,
            child: product.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl.startsWith('http')
                        ? product.imageUrl
                        : '${Strings.imageBaseUrl}${product.imageUrl}',
                    fit: BoxFit.fill,
                    placeholder: (context, url) => AppShimmer(
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) {
                      print("Error loading image: $url - $error");
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
          ),
        ),
        if (product.isNew)
          Positioned(
            top: 8,
            left: 8,
            child: ProductBadge(label: 'NEW'),
          ),
        if (product.discount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: ProductBadge(
              label: '${product.discount}% OFF',
              color: AppColors.accent,
            ),
          ),
      ],
    );
  }

  Widget _buildCategory() {
    return Text(
      product.category.name,
      style: AppTextStyles.caption.copyWith(
        color: Colors.grey[600],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProductName() {
    return Text(
      product.name,
      style: AppTextStyles.subtitle1,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        if (product.discount > 0) ...[
          Text(
            '\$${product.originalPrice.toStringAsFixed(2)}',
            style: AppTextStyles.bodyText2.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: AppTextStyles.subtitle1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          '${product.rating.toStringAsFixed(1)}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(width: 4),
        Text(
          '(${product.reviewCount})',
          style: AppTextStyles.caption.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}