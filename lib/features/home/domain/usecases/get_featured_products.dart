import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/featured_product.dart';
import '../repositories/featured_product_repository.dart';


class GetFeaturedProducts {
  final FeaturedProductsRepository repository;

  GetFeaturedProducts(this.repository);

  Future<Either<Failure, List<FeaturedProduct>>> call() {
    return repository.getFeaturedProducts();
  }
}