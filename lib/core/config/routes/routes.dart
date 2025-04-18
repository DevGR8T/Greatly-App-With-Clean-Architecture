import 'package:flutter/material.dart';
import 'package:greatly_user/features/auth/presentation/pages/login_page.dart';
import 'package:greatly_user/features/main/presentation/pages/main_page.dart';
import 'package:greatly_user/features/onboarding/presentation/pages/onboarding_page.dart';
import '../../../features/auth/presentation/pages/password_reset_page.dart';
import '../../../features/auth/presentation/pages/register_page.dart';
import '../../../features/auth/presentation/pages/splash_page.dart';
import '../../../features/home/presentation/pages/homepage.dart';

/// AppRouter manages all the routes in the application.
class AppRouter {
  // Route names for navigation
   static const String splash = '/splash'; // Add splash route
  static const String login = '/'; // Default route for the login page
  static const String register = '/register'; // Route for the registration page
  static const String home = '/home'; // Route for the home page
  static const String passwordReset = '/password-reset'; // Route for the forgot password page
  static const String onboarding = '/onboarding'; // Route for the onboarding page
  static const String main = '/main'; // Route for the main page


  /// Generates routes based on the route name.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      //Navigate to the splash page 
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        // Navigate to the LoginPage
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        // Navigate to the RegisterPage
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case home:
        // Navigate to the HomePage
        return MaterialPageRoute(builder: (_) => HomePage());
           case passwordReset:
        // Navigate to the passwordreset page
        return MaterialPageRoute(builder: (_) => PasswordResetPage());
           case onboarding:
        // Navigate to the passwordreset page
        return MaterialPageRoute(builder: (_) => OnboardingPage());
         case main:
        // Navigate to the mainpage
        return MaterialPageRoute(builder: (_) => MainView());
      default:
        // Default route if no match is found
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}