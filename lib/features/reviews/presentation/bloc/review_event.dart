// lib/features/reviews/presentation/bloc/review_event.dart
part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class FetchProductReviews extends ReviewEvent {
  final String productId;

  const FetchProductReviews({required this.productId});

  @override
  List<Object> get props => [productId];
}

class CheckUserReviewEligibility extends ReviewEvent {
  final String productId;

  const CheckUserReviewEligibility({required this.productId});

  @override
  List<Object> get props => [productId];
}

class SubmitProductReview extends ReviewEvent {
  final String productId;
  final double rating;
  final String comment;

  const SubmitProductReview({
    required this.productId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object> get props => [productId, rating, comment];
}