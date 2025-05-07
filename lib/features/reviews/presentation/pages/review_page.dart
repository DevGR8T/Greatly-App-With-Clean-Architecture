// lib/features/reviews/presentation/pages/review_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/features/reviews/presentation/widgets/average_rating_display_widget.dart';
import 'package:greatly_user/features/reviews/presentation/widgets/review_form_widget.dart';
import 'package:greatly_user/features/reviews/presentation/widgets/review_list_widget.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/components/app_shimmer.dart';
import '../../../../shared/components/error_state.dart';
import '../bloc/review_bloc.dart';
import '../widgets/review_empty_state.dart';
import '../widgets/review_eligibility_widget.dart';

class ReviewPage extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewPage({
    Key? key,
    required this.productId,
    required this.productName,
  }) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late ReviewBloc _reviewBloc;

  @override
  void initState() {
    super.initState();
    _reviewBloc = getIt<ReviewBloc>();
    _loadReviews();
    _checkEligibility();
  }

  void _loadReviews() {
    _reviewBloc.add(FetchProductReviews(productId: widget.productId));
  }

  void _checkEligibility() {
    _reviewBloc.add(CheckUserReviewEligibility(productId: widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${widget.productName}'),
        elevation: 0,
      ),
      // Set this to false to handle resizing manually with SingleChildScrollView
      resizeToAvoidBottomInset: false, 
      body: BlocProvider.value(
        value: _reviewBloc,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // First part: Average Rating and Summary
                _buildReviewSummary(),
                
                // Second part: User Review Eligibility
                _buildUserReviewSection(),
                
                // Third part: Review List - Wrapped in Container with fixed height
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: _buildReviewListSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewSummary() {
    return BlocBuilder<ReviewBloc, ReviewState>(
      buildWhen: (previous, current) => 
        current is ReviewLoading || current is ReviewsLoaded || current is ReviewError,
      builder: (context, state) {
        if (state is ReviewLoading) {
          return AppShimmer(
              child: Container(color: Colors.white),
            );
        } else if (state is ReviewsLoaded) {
          return AverageRatingDisplay(
            averageRating: state.averageRating,
            reviewCount: state.reviews.length,
          );
        } else if (state is ReviewError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: _loadReviews,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUserReviewSection() {
    return BlocBuilder<ReviewBloc, ReviewState>(
      buildWhen: (previous, current) => 
        current is ReviewEligibilityChecking || 
        current is ReviewEligibilityChecked || 
        current is ReviewSubmitting ||
        current is ReviewSubmissionSuccess ||
        current is ReviewSubmissionFailed,
      builder: (context, state) {
        if (state is ReviewEligibilityChecking) {
          return  Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: SizedBox.shrink()),
          );
        } else if (state is ReviewEligibilityChecked) {
          if (state.canReview) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ReviewForm(
                productId: widget.productId,
                onSubmit: (rating, comment) {
                  _reviewBloc.add(SubmitProductReview(
                    productId: widget.productId,
                    rating: rating,
                    comment: comment,
                  ));
                },
              ),
            );
          } else {
            return ReviewEligibilityWidget(
              productId: widget.productId,
              onBrowseProducts: () {
                Navigator.of(context).pop();
              },
            );
          }
        } else if (state is ReviewSubmitting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ReviewSubmissionFailed) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.red.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Failed to submit review: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _checkEligibility,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildReviewListSection() {
    return BlocBuilder<ReviewBloc, ReviewState>(
      buildWhen: (previous, current) => 
        current is ReviewLoading || current is ReviewsLoaded || current is ReviewError,
      builder: (context, state) {
        if (state is ReviewLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ReviewsLoaded) {
          if (state.reviews.isEmpty) {
            return const ReviewEmptyState();
          }
          return ReviewList(reviews: state.reviews);
        } else if (state is ReviewError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: _loadReviews,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}