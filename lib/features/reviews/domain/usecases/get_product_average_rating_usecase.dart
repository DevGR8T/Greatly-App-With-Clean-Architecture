import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/review_repository.dart';

class GetProductAverageRatingUseCase implements UseCase<double, String> {
  final ReviewRepository repository;

  GetProductAverageRatingUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(String productId) {
    return repository.getProductAverageRating(productId);
  }
}