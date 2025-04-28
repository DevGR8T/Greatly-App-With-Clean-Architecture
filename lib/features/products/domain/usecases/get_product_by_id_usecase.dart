// lib/features/product/domain/usecases/get_product_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/products/domain/repository/product_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';


class GetProductByIdUseCase implements UseCase<Product, String> {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(String productId) {
    return repository.getProductById(productId);
  }
}