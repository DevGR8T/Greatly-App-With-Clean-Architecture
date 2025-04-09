import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_onboarding_items_usecase.dart';
import '../../domain/usecases/set_onboarding_completed_usecase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingItemsUseCase getOnboardingItemsUseCase; // Use case to fetch onboarding items
  final SetOnboardingCompletedUseCase setOnboardingCompletedUseCase; // Use case to mark onboarding as completed

  int currentIndex = 0; // Tracks the current page index

  OnboardingBloc({
    required this.getOnboardingItemsUseCase,
    required this.setOnboardingCompletedUseCase,
  }) : super(OnboardingInitial()) {
    // Handle the event to load onboarding items
    on<LoadOnboardingItemsEvent>((event, emit) {
      try {
        // Fetch onboarding items using the use case
        final items = getOnboardingItemsUseCase();
        // Determine if the current page is the last page
        final isLastPage = currentIndex == items.length - 1;
        // Emit the loaded state with the fetched items
        emit(OnboardingLoaded(
          items: items, 
          currentIndex: currentIndex,
          isLastPage: isLastPage,
        ));
      } catch (e) {
        // Emit an error state if loading fails
        emit(OnboardingError(message: 'Failed to load onboarding items.'));
      }
    });

    // Handle the event when the page changes
    on<OnboardingPageChangedEvent>((event, emit) {
      currentIndex = event.index; // Update the current page index
      if (state is OnboardingLoaded) {
        final loadedState = state as OnboardingLoaded;
        // Determine if the new page is the last page
        final isLastPage = currentIndex == loadedState.items.length - 1;
        // Emit the updated state with the new page index
        emit(OnboardingLoaded(
          items: loadedState.items, 
          currentIndex: currentIndex,
          isLastPage: isLastPage,
        ));
      }
    });

    // Handle the event to navigate to the next page
    on<RequestNextPageEvent>((event, emit) {
      if (state is OnboardingLoaded) {
        final loadedState = state as OnboardingLoaded;
        final nextIndex = currentIndex + 1; // Calculate the next page index
        
        // Only proceed if the next page is within bounds
        if (nextIndex < loadedState.items.length) {
          currentIndex = nextIndex; // Update the current page index
          // Determine if the new page is the last page
          final isLastPage = currentIndex == loadedState.items.length - 1;
          // Emit the updated state with the new page index
          emit(OnboardingLoaded(
            items: loadedState.items, 
            currentIndex: currentIndex,
            isLastPage: isLastPage,
          ));
        }
      }
    });

    // Handle the event to complete the onboarding process
    on<CompleteOnboardingEvent>((event, emit) async {
      // Mark onboarding as completed using the use case
      await setOnboardingCompletedUseCase(event.completed);
      // Emit the completed state
      emit(OnboardingCompleted());
    });
  }
}