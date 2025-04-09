import '../entities/onboarding_item.dart';

/// Defines the contract for data operations in the onboarding flow.
abstract class OnboardingRepository {
  /// Marks the onboarding process as completed.
  /// [completed] - A boolean indicating whether onboarding is completed.
  Future<void> setOnboardingCompleted(bool completed);

  /// Checks if the onboarding process has been completed.
  /// Returns `true` if onboarding is completed, otherwise `false`.
  bool isOnboardingCompleted();

  /// Fetches the list of onboarding items.
  /// Returns a list of [OnboardingItem].
  List<OnboardingItem> getOnboardingItems();
}