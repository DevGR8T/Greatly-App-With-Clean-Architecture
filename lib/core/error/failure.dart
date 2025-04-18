import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Represents a server-related failure.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Represents a failure related to caching.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Represents a failure due to no internet connection.
class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

/// Represents a failure when a user is not found.
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure(super.message);
}