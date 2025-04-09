import '../../../../core/constants/strings.dart';
import '../../domain/entities/onboarding_item.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/local/onboarding_local_data_source.dart';

/// Implementation of the OnboardingRepository interface.
class OnboardingRepositoryImpl implements OnboardingRepository {
  /// Local data source for managing onboarding data.
  final OnboardingLocalDataSource localDataSource;

  /// Constructor to initialize the repository with the local data source.
  OnboardingRepositoryImpl(this.localDataSource);

  /// Marks the onboarding process as completed.
  @override
  Future<void> setOnboardingCompleted(bool completed) {
    return localDataSource.setOnboardingCompleted(completed);
  }

  /// Checks if the onboarding process has been completed.
  @override
  bool isOnboardingCompleted() {
    return localDataSource.isOnboardingCompleted();
  }

  /// Retrieves the list of onboarding items to display to the user.
  @override
  List<OnboardingItem> getOnboardingItems() {
    return [
      OnboardingItem(
        title: Strings.onboardingTitle1, // Title of the first onboarding item
        description: Strings.onboardingDescription1, // Description of the first onboarding item
        imageUrl: 'assets/images/onboarding1.png', // Image for the first onboarding item
      ),
      OnboardingItem(
        title: Strings.onboardingTitle2, // Title of the second onboarding item
        description: Strings.onboardingDescription2, // Description of the second onboarding item
        imageUrl: 'assets/images/onboarding2.png', // Image for the second onboarding item
      ),
      OnboardingItem(
        title: Strings.onboardingTitle3, // Title of the third onboarding item
        description: Strings.onboardingDescription3, // Description of the third onboarding item
        imageUrl: 'assets/images/onboarding3.png', // Image for the third onboarding item
      ),
    ];
  }
}