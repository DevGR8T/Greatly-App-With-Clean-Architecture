import 'package:dartz/dartz.dart';
import 'package:greatly_user/core/error/failure.dart';

/// Base class for all use cases.
///
/// [Type] is the return type, and [Params] is the input parameter type.
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters.
  Future<Either<Failure, Type>> call(Params params);
}

/// Represents no parameters for use cases that don't require input.
class NoParams {}