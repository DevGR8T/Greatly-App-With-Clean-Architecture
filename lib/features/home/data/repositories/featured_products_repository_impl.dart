import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/featured_product.dart';
import '../../domain/repositories/featured_product_repository.dart';
import '../datasources/remote/featured_remote_data_source.dart';

/// Implementation of [FeaturedProductsRepository] to manage featured products.
class FeaturedProductsRepositoryImpl implements FeaturedProductsRepository {
  final FeaturedProductsRemoteDataSource remoteDataSource; // Remote data source for featured products.
  final NetworkInfo networkInfo; // Checks network connectivity.

  /// Initializes the repository with required dependencies.
  FeaturedProductsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Fetches featured products from the remote data source if connected to the internet.
  ///
  /// Returns a [Failure] if there's no connection or a server error occurs.
  @override
  Future<Either<Failure, List<FeaturedProduct>>> getFeaturedProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getFeaturedProducts();
        return Right(remoteProducts);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }
}