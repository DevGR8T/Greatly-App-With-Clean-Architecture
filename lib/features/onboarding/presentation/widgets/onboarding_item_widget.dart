import 'package:flutter/material.dart';
import 'package:greatly_user/core/theme/app_colors.dart';
import '../../domain/entities/onboarding_item.dart';

/// A widget to display a single onboarding item.
/// This widget shows an image, title, and description for the onboarding step.
class OnboardingItemWidget extends StatelessWidget {
  final OnboardingItem item; // The onboarding item to display

  OnboardingItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
      children: [
        // Display the image for the onboarding item
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5, // Use half the screen height
          child: Image.asset(item.imageUrl), // Load the image from assets
        ),
        // Display the title of the onboarding item
        Text(
          item.title,
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: AppColors.surface,
          ),
        ),
        SizedBox(height: 10), // Add spacing between title and description
        // Display the description of the onboarding item
        Text(
          item.description,
          style: TextStyle(
            fontSize: 16, 
            color: AppColors.surface,
          ),
          textAlign: TextAlign.center, // Center-align the text
        ),
      ],
    );
  }
}