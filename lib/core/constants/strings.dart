class Strings {
  // General
  static const String welcomeBack = 'Welcome Back!';
  static const String signInToAccount = 'Sign in to your account.';
  static const String forgotPassword = 'Forgot Password?';
  static const String login = 'Login';
  static const String orContinueWith = 'Or Continue With';
  static const String notAMember = 'Not A Member?';
  static const String joinNow = 'Join Now';
  static const String welcomeAccountCreated = 'Registration successful!';
  static const String loggedIn = 'Login successfully!';
  static const String ok = 'OK';
  static const String resendEmail = 'Resend Email';
  static const String emailVerificationRequired = 'You need to verify your email before logging in. Please check your inbox.';
  static const String verificationEmailSent = 'Verification email sent! Please check your inbox.';
  static const String emailVerificationResent = 'Verification email resent!';
  static const String dialogTitle = '📩 Email Verification Sent';
  static String dialogtext(String email) => 'We\'ve sent a verification email to $email. Click the link in the email to verify your account.';
  // Labels
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';

  // Error Messages of textfield
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
 


// Forgot Password
  static const String forgotPasswordText = 'Forgot Password';
  static const String enterEmailForReset = 'Enter your email address below, and we\'ll send you a link to reset it.';
  static const String passwordResetEmailSent = 'Password reset link sent!';
  static const String passwordResetFailed = 'No account found with this email';
  static const String send = 'Send Reset Link';


  // Routes
  static const String signupRoute = '/register';
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String passwordResetRoute = '/password-reset';
  static const String splashRoute = '/splash';  
}