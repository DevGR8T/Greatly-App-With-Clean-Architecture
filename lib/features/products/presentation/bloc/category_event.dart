import 'package:equatable/equatable.dart';

/// Base class for all category-related events.
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch categories, with an optional refresh flag.
class GetCategories extends CategoryEvent {
  final bool refresh; // Indicates whether to refresh the category list.

  const GetCategories({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}