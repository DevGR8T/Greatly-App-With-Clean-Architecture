import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/features/main/presentation/bloc/navigation_event.dart';
import 'package:greatly_user/features/main/presentation/bloc/navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateToTab>(_onNavigateToTab);
  }
  
  Future<void> _onNavigateToTab(NavigateToTab event, Emitter<NavigationState> emit) async {
    // Skip loading state if navigating to the same tab
    if (state.currentIndex == event.index) return;
    
    // Show loading indicator
    emit(state.copyWith(isLoading: true));
    
    // Simulate a refresh/loading time (you can remove this if you want immediate navigation)
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Navigate to the new tab and hide loading indicator
    emit(state.copyWith(
      currentIndex: event.index,
      isLoading: false,
    ));
  }
}