import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/banner.dart';
import '../repositories/banner_repository.dart';

class GetBanners {
  final BannerRepository repository;

  GetBanners(this.repository);

  Future<Either<Failure, List<Banner>>> call() {
    return repository.getBanners();
  }
}