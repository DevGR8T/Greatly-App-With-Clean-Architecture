import 'package:dartz/dartz.dart';
import 'package:greatly_user/features/products/domain/repository/category_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/category.dart';
import '../datasources/remote/category_remote_data_source.dart';

/// Implementation of [CategoryRepository] to manage category data.
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource; // Remote data source for categories.
  final NetworkInfo networkInfo; // Checks network connectivity.

  /// Initializes the repository with required dependencies.
  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Fetches categories from the remote data source if connected to the internet.
  ///
  /// Returns a [Failure] if there's no connection or a server error occurs.
  @override
  Future<Either<Failure, List<Category>>> getCategories(bool refresh) async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getCategories();
        return Right(categories);
      } on ServerException {
        return Left(ServerFailure('Failed to fetch categories from the server'));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }
}