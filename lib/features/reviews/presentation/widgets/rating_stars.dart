import 'package:flutter/material.dart';

/// A widget that displays a star rating with optional text.
/// 
/// This widget is used consistently across the app to display ratings
/// for products, including on the product detail page and review page.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showRatingText;
  final int? reviewCount;
  final TextStyle? ratingTextStyle;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 20,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.showRatingText = false,
    this.reviewCount,
    this.ratingTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              // Full star
              return Icon(
                Icons.star,
                color: activeColor,
                size: size,
              );
            } else if (index == rating.floor() && rating % 1 > 0) {
              // Half star
              return Icon(
                Icons.star_half,
                color: activeColor,
                size: size,
              );
            } else {
              // Empty star
              return Icon(
                Icons.star_border,
                color: inactiveColor,
                size: size,
              );
            }
          }),
        ),
        if (showRatingText) ...[
          const SizedBox(width: 8),
          Text(
            reviewCount != null
                ? '${rating.toStringAsFixed(1)} ($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})'
                : rating.toStringAsFixed(1),
            style: ratingTextStyle ?? TextStyle(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}