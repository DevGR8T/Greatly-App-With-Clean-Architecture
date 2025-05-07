// lib/features/reviews/presentation/bloc/review_state.dart
part of 'review_bloc.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  
  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  final double averageRating;

  const ReviewsLoaded({
    required this.reviews,
    required this.averageRating,
  });

  @override
  List<Object> get props => [reviews, averageRating];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError({required this.message});

  @override
  List<Object> get props => [message];
}

class ReviewEligibilityChecking extends ReviewState {}

class ReviewEligibilityChecked extends ReviewState {
  final bool canReview;

  const ReviewEligibilityChecked({required this.canReview});

  @override
  List<Object> get props => [canReview];
}

class ReviewSubmitting extends ReviewState {}

class ReviewSubmissionSuccess extends ReviewState {
  final Review review;

  const ReviewSubmissionSuccess({required this.review});

  @override
  List<Object> get props => [review];
}

class ReviewSubmissionFailed extends ReviewState {
  final String message;

  const ReviewSubmissionFailed({required this.message});

  @override
  List<Object> get props => [message];
}