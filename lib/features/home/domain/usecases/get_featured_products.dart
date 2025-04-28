import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/featured_product.dart';
import '../repositories/featured_product_repository.dart';

/// Use case to retrieve a list of featured products.
class GetFeaturedProducts {
  /// The repository that provides access to featured products data.
  final FeaturedProductsRepository repository;

  /// Creates an instance of [GetFeaturedProducts] with the given repository.
  GetFeaturedProducts(this.repository);

  /// Retrieves a list of featured products.
  ///
  /// Returns an [Either] containing a [Failure] in case of an error,
  /// or a list of [FeaturedProduct] on success.
  Future<Either<Failure, List<FeaturedProduct>>> call() {
    return repository.getFeaturedProducts();
  }
}