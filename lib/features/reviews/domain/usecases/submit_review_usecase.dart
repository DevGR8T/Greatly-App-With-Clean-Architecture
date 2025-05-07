import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class SubmitReviewUseCase implements UseCase<Review, SubmitReviewParams> {
  final ReviewRepository repository;

  SubmitReviewUseCase(this.repository);

  @override
  Future<Either<Failure, Review>> call(SubmitReviewParams params) {
    return repository.submitReview(
      productId: params.productId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}
class SubmitReviewParams extends Equatable {
  final String productId;
  final double rating;
  final String comment;

  const SubmitReviewParams({
    required this.productId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [productId, rating, comment];
}