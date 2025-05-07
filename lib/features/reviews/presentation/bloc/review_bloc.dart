// lib/features/reviews/presentation/bloc/review_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_product_reviews_usecase.dart';
import '../../domain/usecases/get_product_average_rating_usecase.dart';
import '../../domain/usecases/has_user_review_product_usecase.dart';
import '../../domain/usecases/submit_review_usecase.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetProductReviewsUseCase getProductReviews;
  final GetProductAverageRatingUseCase getProductAverageRating;
  final HasUserReviewedProductUseCase hasUserReviewedProduct;
  final SubmitReviewUseCase submitReview;

  ReviewBloc({
    required this.getProductReviews,
    required this.getProductAverageRating,
    required this.hasUserReviewedProduct,
    required this.submitReview,
  }) : super(ReviewInitial()) {
    on<FetchProductReviews>(_onFetchProductReviews);
    on<CheckUserReviewEligibility>(_onCheckUserReviewEligibility);
    on<SubmitProductReview>(_onSubmitProductReview);
  }

Future<void> _onFetchProductReviews(
  FetchProductReviews event,
  Emitter<ReviewState> emit,
) async {
  emit(ReviewLoading());
  
  try {
    // Get average rating
    final averageRatingResult = await getProductAverageRating(event.productId);
    
    // Get reviews
    final reviewsResult = await getProductReviews(event.productId);
    
    reviewsResult.fold(
      (failure) => emit(ReviewError(message: failure.message)),
      (reviews) {
        averageRatingResult.fold(
          (failure) => emit(ReviewError(message: failure.message)),
          (averageRating) => emit(ReviewsLoaded(
            reviews: reviews,
            averageRating: averageRating,
          )),
        );
      },
    );
  } catch (e) {
    print("Error in _onFetchProductReviews: $e");
    emit(ReviewError(message: "Could not load reviews. Please try again."));
  }
}

  Future<void> _onCheckUserReviewEligibility(
    CheckUserReviewEligibility event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewEligibilityChecking());
    
    final result = await hasUserReviewedProduct(event.productId);
    
    result.fold(
      (failure) => emit(ReviewError(message: failure.message)),
      (hasReviewed) => emit(ReviewEligibilityChecked(
        canReview: !hasReviewed,
      )),
    );
  }

  Future<void> _onSubmitProductReview(
    SubmitProductReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());
    
    final params = SubmitReviewParams(
      productId: event.productId,
      rating: event.rating,
      comment: event.comment,
    );
    
    final result = await submitReview(params);
    
    
    result.fold(
      (failure) => emit(ReviewSubmissionFailed(message: failure.message)),
      (review) => emit(ReviewSubmissionSuccess(review: review)),
    );
    
    // Refetch reviews after successful submission
    add(FetchProductReviews(productId: event.productId));
  }
}