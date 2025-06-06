/// A collection of user-friendly error messages for various authentication errors.
class ErrorMessages {
  /// Default fallback for unexpected errors.
  static const String unexpectedError = 'An unexpected error occurred.';

  /// Error message for invalid email or password.
  static const String invalidCredentials = 'Invalid email or password.';

  /// Error message when no account is found for the provided email.
  static const String userNotFound = 'Email address not found.';

  /// Error message when the email address is already in use.
  static const String emailAlreadyInUse = 'The email address is already in use.';

  /// Error message for Google registration failure.
  static const String googleRegistrationFailed = 'Google registration failed';

  /// Error message for sign-in cancellation.
  static const String signInCanceled = 'Sign-in canceled. Try again.';

  /// Error message for network issues.
  static const String networkError = 'Check your connection and retry.';

  /// Error message for missing email during sign-in.
  static const String noEmailFound = 'No email found. Use a different account.';

  static const String emailNotVerified = 'Please Verify your email to log in.';

    /// Retrieves the error message based on the provided key.
  static String getErrorMessage(String key) {
    switch (key) {
      case 'invalid-credentials':
        return invalidCredentials;
      case 'user-not-found':
        return userNotFound;
      case 'email-already-in-use':
        return emailAlreadyInUse;
      case 'google-registration-failed':
        return googleRegistrationFailed;
      case 'sign-in-canceled':
        return signInCanceled;
      case 'network-error':
        return networkError;
      case 'no-email-found':
        return noEmailFound;
      case 'email-not-verified':
        return emailNotVerified;
      default:
        return unexpectedError;
    }
  }
}