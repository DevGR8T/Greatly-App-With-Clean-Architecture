import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/review_repository.dart';

class HasUserReviewedProductUseCase implements UseCase<bool, String> {
  final ReviewRepository repository;

  HasUserReviewedProductUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String productId) {
    return repository.hasUserReviewedProduct(productId);
  }
}