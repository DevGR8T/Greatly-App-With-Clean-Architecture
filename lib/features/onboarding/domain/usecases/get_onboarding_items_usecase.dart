import '../repositories/onboarding_repository.dart';
import '../entities/onboarding_item.dart';

/// Use case to fetch the list of onboarding items.
class GetOnboardingItemsUseCase {
  final OnboardingRepository repository; // Repository to handle onboarding data

  /// Constructor to initialize the repository.
  GetOnboardingItemsUseCase(this.repository);

  /// Fetches the list of onboarding items.
  /// Returns a list of [OnboardingItem].
  List<OnboardingItem> call() {
    return repository.getOnboardingItems();
  }
}