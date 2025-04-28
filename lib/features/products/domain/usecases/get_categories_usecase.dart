import 'package:dartz/dartz.dart';
import 'package:greatly_user/core/error/failure.dart';
import 'package:greatly_user/features/products/domain/entities/category.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/category_repository.dart';

/// Use case to fetch categories from the repository.
class GetCategoriesUseCase implements UseCase<List<Category>, bool> {
  final CategoryRepository repository; // Repository to fetch categories.

  GetCategoriesUseCase(this.repository);

  /// Executes the use case with the given refresh parameter.
  ///
  /// [refresh] determines whether to fetch fresh data or use cached data.
  @override
  Future<Either<Failure, List<Category>>> call(bool refresh) {
    return repository.getCategories(refresh);
  }
}