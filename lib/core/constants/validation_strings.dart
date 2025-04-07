/// Validation error messages.
class ValidationStrings {
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Enter a valid email';

  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';

  static const String usernameRequired = 'Username is required';
  static const String usernameTooShort = 'Username must be at least 3 characters';

  static const String phoneNumberRequired = 'Phone number is required';
  static const String invalidPhoneNumber = 'Enter a valid phone number';
}

/// Validation regex patterns.
class ValidationPatterns {
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\d{10,15}$';
}

/// Validation rules (e.g., minimum lengths).
class ValidationRules {
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
}