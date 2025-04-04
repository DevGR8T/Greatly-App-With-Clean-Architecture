import '../constants/error_messages.dart';

class ErrorUtils {
  /// Cleans up error messages for better user readability.
  static String cleanErrorMessage(String errorMessage) {
    if (errorMessage.contains('email-already-in-use')) {
      return ErrorMessages.emailAlreadyInUse;
    }
    if (errorMessage.contains('google-sign-in-canceled') ) {
      return ErrorMessages.googleRegistrationFailed;
    }
    if (errorMessage.contains('user-not-found') || errorMessage.contains('Email address not found')) {
      return ErrorMessages.userNotFound;
    }
    if (errorMessage.contains('wrong-password') || errorMessage.contains('invalid-credential')) {
      return ErrorMessages.invalidCredentials;
    }
   if (errorMessage.contains('invalid-credential')) {
      return ErrorMessages.invalidCredentials;
    }
  if (errorMessage.contains('Email not verified. Please verify your email before logging in')) {
  return ErrorMessages.emailNotVerified;
}
    return errorMessage; // Instead of returning a generic error, return the actual message
  }
}



