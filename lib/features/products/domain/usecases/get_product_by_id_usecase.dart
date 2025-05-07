import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/products/domain/repository/product_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';

/// Use case to fetch a product by its ID.
class GetProductByIdUseCase implements UseCase<Product, String> {
  final ProductRepository repository;

  /// Initializes the use case with the product repository.
  GetProductByIdUseCase(this.repository);

  /// Executes the use case to fetch a product by its ID.
  /// Returns either a [Failure] or the [Product].
  @override
  Future<Either<Failure, Product>> call(String productId) {
    return repository.getProductById(productId);
  }
}