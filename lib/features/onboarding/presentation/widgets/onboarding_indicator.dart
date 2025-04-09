import 'package:flutter/material.dart';

/// A widget that displays a row of indicators for the onboarding pages.
class OnboardingIndicator extends StatelessWidget {
  /// Total number of onboarding pages.
  final int count;

  /// The index of the currently active page.
  final int currentIndex;

  /// Constructor to initialize the indicator with the total count and current index.
  OnboardingIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the indicators horizontally
      children: List.generate(
        count,
        (index) => Container(
          width: 10, // Width of each indicator
          height: 8, // Height of each indicator
          margin: EdgeInsets.symmetric(horizontal: 5), // Spacing between indicators
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Circular shape for the indicators
            color: currentIndex == index ? Colors.white : Colors.grey, // Highlight the active indicator
          ),
        ),
      ),
    );
  }
}