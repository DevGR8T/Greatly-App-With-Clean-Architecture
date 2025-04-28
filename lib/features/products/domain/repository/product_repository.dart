import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/product.dart';
import '../usecases/get_products_usecase.dart';

/// Repository interface for managing product-related operations.
abstract class ProductRepository {
  /// Fetches a list of products with optional filters and pagination.
  Future<Either<Failure, ProductData>> getProducts({
    String? query, // Search query.
    String? categoryId, // ID of the selected category.
    String? sortOption, // Sorting option (e.g., price, rating).
    int page = 1, // Current page number for pagination.
    bool refresh = false, // Indicates if the cache should be refreshed.
  });

  /// Fetches a single product by its ID.
  Future<Either<Failure, Product>> getProductById(String id);
}