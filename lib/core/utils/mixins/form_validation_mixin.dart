import '../../constants/validation_strings.dart';


/// A mixin that provides common form validation methods.
mixin FormValidationMixin {
  /// Validates an email address.
  /// Returns an error message if the email is invalid or null, otherwise null.
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationStrings.emailRequired;
    }
    final emailRegex = RegExp(ValidationPatterns.emailRegex);
    if (!emailRegex.hasMatch(value.trim())) {
      return ValidationStrings.invalidEmail;
    }
    return null;
  }

  /// Validates a password.
  /// Returns an error message if the password is invalid or null, otherwise null.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationStrings.passwordRequired;
    }
    if (value.length < ValidationRules.minPasswordLength) {
      return ValidationStrings.passwordTooShort;
    }
    return null;
  }

  /// Validates a username.
  /// Returns an error message if the username is invalid or null, otherwise null.
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationStrings.usernameRequired;
    }
    if (value.trim().length < ValidationRules.minUsernameLength) {
      return ValidationStrings.usernameTooShort;
    }
    return null;
  }

  /// Validates a phone number.
  /// Returns an error message if the phone number is invalid or null, otherwise null.
  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationStrings.phoneNumberRequired;
    }
    if (!RegExp(ValidationPatterns.phoneRegex).hasMatch(value)) {
      return ValidationStrings.invalidPhoneNumber;
    }
    return null;
  }
}