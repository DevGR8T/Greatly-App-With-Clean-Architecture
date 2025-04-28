import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/banner.dart';

/// Abstract repository to manage banner data.
abstract class BannerRepository {
  /// Fetches a list of banners or returns a failure.
  Future<Either<Failure, List<Banner>>> getBanners();
}