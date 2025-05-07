import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProductBadge extends StatelessWidget {
  final String label; // Text to display on the badge.
  final Color? color; // Background color of the badge.

  const ProductBadge({
    Key? key,
    required this.label,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Access the app's text theme.

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? AppColors.primary, // Default to primary color if none provided.
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith( // Use labelLarge from the app's text theme.
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}