import '../repositories/onboarding_repository.dart';

/// Use case to check if onboarding is completed.
class IsOnboardingCompletedUseCase {
  final OnboardingRepository repository; // Repository to handle onboarding data

  /// Constructor to initialize the repository.
  IsOnboardingCompletedUseCase(this.repository);

  /// Checks if the onboarding process has been completed.
  /// Returns `true` if onboarding is completed, otherwise `false`.
  bool call() {
    return repository.isOnboardingCompleted();
  }
}