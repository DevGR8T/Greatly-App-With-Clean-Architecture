abstract class Failure {
  final String message;

  Failure({required this.message}); // Use named parameter
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message: message); // Pass named parameter
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message: message); // Pass named parameter
}

class UserNotFoundFailure extends Failure {
  UserNotFoundFailure(String message) : super(message: message); // Pass named parameter
}