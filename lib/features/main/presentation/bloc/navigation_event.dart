// navigation_event.dart
import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class NavigateToTab extends NavigationEvent {
  final int index;
  NavigateToTab(this.index);
  
  @override
  List<Object> get props => [index]; 
}