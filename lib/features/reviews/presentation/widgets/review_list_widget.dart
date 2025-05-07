// lib/features/reviews/presentation/widgets/review_list.dart
import 'package:flutter/material.dart';
import 'package:greatly_user/features/reviews/presentation/widgets/review_item_widget.dart';
import '../../domain/entities/review.dart';


class ReviewList extends StatelessWidget {
  final List<Review> reviews;

  const ReviewList({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewItem(review: review);
      },
    );
  }
}