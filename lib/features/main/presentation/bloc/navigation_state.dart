import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int currentIndex;
  final bool isLoading;
  
  const NavigationState({
    this.currentIndex = 0,
    this.isLoading = false,
  });
  
  NavigationState copyWith({
    int? currentIndex,
    bool? isLoading,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object> get props => [currentIndex, isLoading];
}