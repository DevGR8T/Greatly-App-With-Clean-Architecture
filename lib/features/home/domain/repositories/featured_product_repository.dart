import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/featured_product.dart';

abstract class FeaturedProductsRepository {
  Future<Either<Failure, List<FeaturedProduct>>> getFeaturedProducts();
}