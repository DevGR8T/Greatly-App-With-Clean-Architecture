import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/banner.dart';
import '../repositories/banner_repository.dart';

/// Use case to fetch a list of banners.
class GetBanners {
  final BannerRepository repository; // Repository to access banner data.

  /// Initializes the use case with the given repository.
  GetBanners(this.repository);

  /// Fetches banners from the repository.
  ///
  /// Returns an [Either] with a [Failure] on error or a list of [Banner] on success.
  Future<Either<Failure, List<Banner>>> call() {
    return repository.getBanners();
  }
}