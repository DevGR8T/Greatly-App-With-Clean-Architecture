import '../repositories/onboarding_repository.dart';

/// Use case to mark the onboarding process as completed.
class SetOnboardingCompletedUseCase {
  final OnboardingRepository repository; // Repository to handle onboarding data

  /// Constructor to initialize the repository.
  SetOnboardingCompletedUseCase(this.repository);

  /// Marks the onboarding process as completed or not.
  /// [completed] - A boolean indicating whether onboarding is completed.
  Future<void> call(bool completed) {
    return repository.setOnboardingCompleted(completed);
  }
}