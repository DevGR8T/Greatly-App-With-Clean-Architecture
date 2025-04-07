abstract class Failure {
  final String message;

  Failure({required this.message}); // Use named parameter
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message: message); 
}



class UserNotFoundFailure extends Failure {
  UserNotFoundFailure(String message) : super(message: message); 
}