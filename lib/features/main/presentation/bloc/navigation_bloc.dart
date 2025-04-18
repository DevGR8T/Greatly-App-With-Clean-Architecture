// navigation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/features/main/presentation/bloc/navigation_event.dart';
import 'package:greatly_user/features/main/presentation/bloc/navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateToTab>(_onNavigateToTab);
  }
  
  void _onNavigateToTab(NavigateToTab event, Emitter<NavigationState> emit) {
    emit(state.copyWith(currentIndex: event.index));
  }
}