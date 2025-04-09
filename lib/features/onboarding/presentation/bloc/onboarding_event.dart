import 'package:equatable/equatable.dart';

/// Base class for all onboarding events.
abstract class OnboardingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// Event to load onboarding items.
/// Triggered to fetch the list of onboarding items.
class LoadOnboardingItemsEvent extends OnboardingEvent {}

/// Event to mark the onboarding process as completed.
/// Triggered when the user finishes the onboarding flow.
class CompleteOnboardingEvent extends OnboardingEvent {
  final bool completed; // Indicates whether onboarding is completed

  CompleteOnboardingEvent({required this.completed});

  @override
  List<Object> get props => [completed];
}

/// Event to handle page changes in the onboarding flow.
/// Triggered when the user navigates to a different page.
class OnboardingPageChangedEvent extends OnboardingEvent {
  final int index; // The index of the current page

  OnboardingPageChangedEvent({required this.index});

  @override
  List<Object> get props => [index];
}

/// Event to request moving to the next page.
/// Triggered when the user clicks the "Next" button.
class RequestNextPageEvent extends OnboardingEvent {}

/// Event to navigate to the home screen.
/// Triggered when onboarding is completed, and the user is redirected to the home screen.
class NavigateToHomeEvent extends OnboardingEvent {}