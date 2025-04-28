

import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/category.dart';

/// Interface for category repository.
abstract class CategoryRepository {
  /// Fetches categories with an optional refresh flag.
  Future<Either<Failure, List<Category>>> getCategories(bool refresh);
}