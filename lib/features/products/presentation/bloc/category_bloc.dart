import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'category_event.dart';
import 'category_state.dart';

/// Bloc to manage category-related events and states.
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase; // Use case to fetch categories.

  /// Initializes the bloc with the required use case.
  CategoryBloc({required this.getCategoriesUseCase}) : super(CategoryInitial()) {
    on<GetCategories>(_onGetCategories); // Handles GetCategories event.
  }

  /// Handles the GetCategories event.
  ///
  /// Emits [CategoryLoading] while fetching data, then either [CategoryLoaded]
  /// on success or [CategoryError] on failure.
  Future<void> _onGetCategories(
    GetCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading()); // Emit loading state.
    final result = await getCategoriesUseCase(event.refresh); // Fetch categories.
    result.fold(
      (failure) => emit(CategoryError(failure.message)), // Emit error state.
      (categories) => emit(CategoryLoaded(categories)), // Emit loaded state.
    );
  }
}