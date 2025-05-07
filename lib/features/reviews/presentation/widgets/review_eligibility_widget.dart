// lib/features/reviews/presentation/widgets/review_eligibility_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/review_bloc.dart';

class ReviewEligibilityWidget extends StatelessWidget {
  final String productId;
  final VoidCallback onBrowseProducts;

  const ReviewEligibilityWidget({
    Key? key,
    required this.productId,
    required this.onBrowseProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      buildWhen: (previous, current) => 
        current is ReviewEligibilityChecking || 
        current is ReviewEligibilityChecked,
      builder: (context, state) {
        if (state is ReviewEligibilityChecking) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ReviewEligibilityChecked) {
          if (!state.canReview) {
            // User has already reviewed the product
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 36,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You have already reviewed this product',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // User can review - we'll handle this in the parent widget
            return const SizedBox.shrink();
          }
        } else {
         
          return SizedBox.shrink();
        }
      },
    );
  }
}