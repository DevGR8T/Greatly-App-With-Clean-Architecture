import 'package:equatable/equatable.dart';
import 'package:greatly_user/features/products/domain/entities/category.dart';


/// Base class for all category-related states.
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action is taken.
class CategoryInitial extends CategoryState {}

/// State when categories are being loaded.
class CategoryLoading extends CategoryState {}

/// State when categories are successfully loaded.
class CategoryLoaded extends CategoryState {
  final List<Category> categories; // List of loaded categories.

  const CategoryLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

/// State when an error occurs while loading categories.
class CategoryError extends CategoryState {
  final String message; // Error message.

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}