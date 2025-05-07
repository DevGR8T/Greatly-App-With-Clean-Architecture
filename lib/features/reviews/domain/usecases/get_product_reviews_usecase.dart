import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetProductReviewsUseCase implements UseCase<List<Review>, String> {
  final ReviewRepository repository;

  GetProductReviewsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Review>>> call(String productId) {
    return repository.getProductReviews(productId);
  }
}