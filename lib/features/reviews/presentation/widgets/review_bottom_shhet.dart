// lib/features/reviews/presentation/widgets/review_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:greatly_user/features/reviews/presentation/widgets/rating_input_widget.dart';
import '../../../../core/constants/validation_strings.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class ReviewBottomSheet extends StatefulWidget {
  final String productId;
  final Function(double rating, String comment) onSubmit;

  const ReviewBottomSheet({
    Key? key,
    required this.productId,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
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
    // Get available height and adjust for keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            
            // Header with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Write a Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Scrollable content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 16),
                  // Rating section
                  const Text(
                    'Your Rating',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 24),
                  
                  // Comment field
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
                   
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            // Submit button - fixed at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}