import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized text styles for consistent typography across the app.
class AppTextStyles {
  // Large headings for primary titles
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  // Medium headings for secondary titles
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  // Small headings for section titles
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  // Headline for smaller titles
  static const TextStyle headline6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );

  // Subtitle for supporting text
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // Standard body text for content
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Smaller body text for secondary content
  static const TextStyle bodyText2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Caption text for small labels or hints
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );

  // Text style for product pricing
  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Text style for discounted prices with strikethrough
  static final TextStyle priceDiscount = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.lineThrough,
    color: Colors.grey[600],
  );

  // Text style for product ratings
  static const TextStyle rating = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.amber,
  );

  // Text style for review counts
  static const TextStyle reviewCount = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  // Text style for product categories
  static const TextStyle category = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  // Text style for buttons
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white, // Default button text color
  );
}