// lib/features/reviews/presentation/widgets/review_form.dart
import 'package:flutter/material.dart';
import 'package:greatly_user/features/reviews/presentation/widgets/rating_input_widget.dart';
import '../../../../core/constants/validation_strings.dart';
import '../../../../shared/widgets/custom_text_field.dart';


class ReviewForm extends StatefulWidget {
  final String productId;
  final Function(double rating, String comment) onSubmit;

  const ReviewForm({
    Key? key,
    required this.productId,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 0;
  bool _showRatingError = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    // Validate rating
    if (_rating == 0) {
      setState(() {
        _showRatingError = true;
      });
      return;
    }

    // Validate form
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_rating, _commentController.text.trim());
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Write a Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Rating selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Rating',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RatingInput(
                      initialRating: _rating,
                      onRatingChanged: (value) {
                        setState(() {
                          _rating = value;
                          _showRatingError = false;
                        });
                      },
                    ),
                    if (_showRatingError)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Please select a rating',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Comment input
                CustomTextField(
                  controller: _commentController,
                  labelText: 'Your Review',
                  hintText: 'Share your experience with this product...',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return ValidationStrings.fieldRequired;
                    }
                    if (value.trim().length < 10) {
                      return 'Review should be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}