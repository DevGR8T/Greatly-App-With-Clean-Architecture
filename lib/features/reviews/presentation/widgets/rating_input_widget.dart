// lib/features/reviews/presentation/widgets/rating_input.dart
import 'package:flutter/material.dart';

class RatingInput extends StatelessWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const RatingInput({
    Key? key,
    required this.initialRating,
    required this.onRatingChanged,
    this.size = 36,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final rating = index + 1.0;
        return GestureDetector(
          onTap: () => onRatingChanged(rating),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              rating <= initialRating ? Icons.star : Icons.star_border,
              color: rating <= initialRating ? activeColor : inactiveColor,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}