import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/banner.dart';
import '../../domain/repositories/banner_repository.dart';
import '../datasources/remote/banner_remote_data_source.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BannerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Banner>>> getBanners() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteBanners = await remoteDataSource.getBanners();
        return Right(remoteBanners);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ConnectionFailure('No internet connection'));
    }
  }
}