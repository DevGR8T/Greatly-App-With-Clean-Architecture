import 'package:equatable/equatable.dart';
import '../../domain/entities/onboarding_item.dart';

/// Base class for all onboarding states.
/// All states in the onboarding flow extend this class.
abstract class OnboardingState extends Equatable {
  @override
  List<Object> get props => [];
}

/// Initial state before any onboarding data is loaded.
/// This is the default state when the onboarding process starts.
class OnboardingInitial extends OnboardingState {}

/// State when onboarding items are being loaded.
/// Indicates that the app is fetching onboarding data.
class OnboardingLoading extends OnboardingState {}

/// State when onboarding items are successfully loaded.
/// Contains the list of onboarding items and the current page index.
class OnboardingLoaded extends OnboardingState {
  final List<OnboardingItem> items; // List of onboarding items
  final int currentIndex; // Current page index
  final bool isLastPage; // Whether the current page is the last one

  OnboardingLoaded({
    required this.items,
    required this.currentIndex,
    required this.isLastPage,
  });

  @override
  List<Object> get props => [items, currentIndex, isLastPage];
}

/// State when the onboarding process is completed.
/// Indicates that the user has finished the onboarding flow.
class OnboardingCompleted extends OnboardingState {}

/// State when there is an error loading onboarding items.
/// Contains an error message describing the issue.
class OnboardingError extends OnboardingState {
  final String message; // Error message

  OnboardingError({required this.message});

  @override
  List<Object> get props => [message];
}