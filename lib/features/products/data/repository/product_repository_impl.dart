import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/products/data/datasources/remote/product_remote_data_source.dart';
import 'package:greatly_user/features/products/domain/entities/product.dart';
import 'package:greatly_user/features/products/domain/repository/product_repository.dart';
import 'package:greatly_user/features/products/domain/usecases/get_products_usecase.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../core/error/failure.dart';


/// Implementation of [ProductRepository] to manage product data.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource; // Remote data source for products.
  final NetworkInfo networkInfo; // Checks network connectivity.

  /// Initializes the repository with required dependencies.
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Fetches products from the remote data source if connected to the internet.
  ///
  /// Returns a [Failure] if there's no connection or a server error occurs.
  @override
  Future<Either<Failure, ProductData>> getProducts({
    String? query,
    String? categoryId,
    String? sortOption,
    int page = 1,
    bool refresh = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getProducts(
          query: query,
          categoryId: categoryId,
          sortOption: sortOption,
          page: page,
        );

        return Right(ProductData(
          products: result['products'],
          hasMore: result['hasMore'],
        ));
      } on ServerException {
        return Left(ServerFailure('Failed to fetch products from the server'));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection. please check your network settings'));
    }
  }

  /// Fetches a single product by its ID from the remote data source.
  ///
  /// Returns a [Failure] if there's no connection or a server error occurs.
  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final product = await remoteDataSource.getProductById(id);
        return Right(product);
      } on ServerException {
        return Left(ServerFailure('Failed to fetch product with ID: $id'));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }
}