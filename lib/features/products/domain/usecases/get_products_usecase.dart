import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:greatly_user/core/error/failure.dart';
import 'package:greatly_user/features/products/domain/repository/product_repository.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';


/// Data class to hold products and pagination info.
class ProductData {
  final List<Product> products; // List of fetched products.
  final bool hasMore; // Indicates if more products are available.

  ProductData({required this.products, required this.hasMore});
}

/// Parameters for fetching products.
class GetProductsParams extends Equatable {
  final String? query; // Search query.
  final String? categoryId; // ID of the selected category.
  final String? sortOption; // Sorting option (e.g., price, rating).
  final int page; // Current page number for pagination.
  final bool refresh; // Indicates if the cache should be refreshed.

  const GetProductsParams({
    this.query,
    this.categoryId,
    this.sortOption,
    this.page = 1,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [query, categoryId, sortOption, page, refresh];
}

/// Use case to fetch products from the repository.
class GetProductsUseCase implements UseCase<ProductData, GetProductsParams> {
  final ProductRepository repository; // Repository to fetch products.

  GetProductsUseCase(this.repository);

  /// Executes the use case with the given parameters.
  @override
  Future<Either<Failure, ProductData>> call(GetProductsParams params) {
    return repository.getProducts(
      query: params.query,
      categoryId: params.categoryId,
      sortOption: params.sortOption,
      page: params.page,
      refresh: params.refresh,
    );
  }
}