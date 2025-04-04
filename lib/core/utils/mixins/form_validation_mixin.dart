/// A mixin that provides common form validation methods.
mixin FormValidationMixin {
  /// Validates an email address.
  /// Returns an error message if the email is invalid or null, otherwise null.
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Validates a password.
  /// Returns an error message if the password is invalid or null, otherwise null.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates a username.
  /// Returns an error message if the username is invalid or null, otherwise null.
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  /// Validates a phone number.
  /// Returns an error message if the phone number is invalid or null, otherwise null.
  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}