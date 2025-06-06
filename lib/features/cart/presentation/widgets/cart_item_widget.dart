import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/components/app_shimmer.dart';
import '../../domain/entities/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;
  final bool isProcessing;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Dismissible(
          key: Key(item.id),
          confirmDismiss: (_) async {
            if (isProcessing) return false;
            onRemove();
            return true;
          },
          background: Container(
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          direction: DismissDirection.endToStart,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(context),
                  Expanded(
                    child: _buildProductDetails(context),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    // Fix #1: Properly format the image URL with base URL if needed
    String imageUrl = item.imageUrl;
    
    // Check if the URL needs the base URL prefix
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${Strings.imageBaseUrl}$imageUrl';
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: imageUrl.isNotEmpty
          ? Hero(
              tag: 'product_${item.id}',
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.fill,
               
                placeholder: (context, url) => AppShimmer(
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) {
                  // Log the error for debugging
                  print("Error loading cart image: $url - $error");
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, color: Colors.grey[400]),
                      const SizedBox(height: 4),
                      Text(
                        'Image Error',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  );
                },
              ),
            )
          : const Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: isProcessing ? null : onRemove,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: isProcessing ? Colors.grey.withOpacity(0.5) : Colors.grey,
                ),
              ),
            ],
          ),
          if (item.variant.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.variant,
              style: AppTextStyles.caption.copyWith(color: Colors.grey),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                style: AppTextStyles.subtitle1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              _buildQuantityControls(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          _buildQuantityButton(
            context,
            icon: Icons.remove,
            onPressed: isProcessing || item.quantity <= 1 ? null : () => onQuantityChanged(item.quantity - 1),
          ),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              '${item.quantity}',
              style: AppTextStyles.bodyText2.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildQuantityButton(
            context,
            icon: Icons.add,
            onPressed: isProcessing ? null : () => onQuantityChanged(item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          size: 16,
          color: onPressed == null 
              ? Colors.grey.shade300 
              : Colors.grey.shade700,
        ),
      ),
    );
  }
}