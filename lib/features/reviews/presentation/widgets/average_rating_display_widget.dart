// lib/features/reviews/presentation/widgets/average_rating_display_widget.dart
import 'package:flutter/material.dart';
import 'rating_stars.dart';

class AverageRatingDisplay extends StatelessWidget {
  final double averageRating;
  final int reviewCount;

  const AverageRatingDisplay({
    Key? key,
    required this.averageRating,
    required this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingStars(
                    rating: averageRating,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}