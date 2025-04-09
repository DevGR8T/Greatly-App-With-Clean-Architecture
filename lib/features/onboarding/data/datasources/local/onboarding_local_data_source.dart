import 'package:shared_preferences/shared_preferences.dart';

/// Handles onboarding data using SharedPreferences.
class OnboardingLocalDataSource {
  /// SharedPreferences instance for local storage.
  final SharedPreferences sharedPreferences;

  /// Constructor to initialize with SharedPreferences.
  OnboardingLocalDataSource(this.sharedPreferences);

  /// Saves the onboarding completion status.
  Future<void> setOnboardingCompleted(bool completed) async {
    await sharedPreferences.setBool('onboarding_completed', completed);
  }

  /// Checks if onboarding is completed.
  bool isOnboardingCompleted() {
    return sharedPreferences.getBool('onboarding_completed') ?? false;
  }
}