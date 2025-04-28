import 'package:equatable/equatable.dart';
import '../widgets/filter_options.dart';

/// Base class for all product-related events.
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch products with optional filters and refresh flag.
class GetProducts extends ProductEvent {
  final String? query; // Search query for filtering products.
  final String? categoryId; // ID of the category to filter products.
  final SortOption? sortOption; // Sorting criteria for products.
  final bool refresh; // Indicates whether to refresh cached data.

  const GetProducts({
    this.query,
    this.categoryId,
    this.sortOption,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [query, categoryId, sortOption, refresh];
}

/// Event to fetch details of a single product by its ID.
class GetProductById extends ProductEvent {
  final String id; // Unique identifier of the product.

 GetProductById({required this.id});

  @override
  List<Object> get props => [id];
}

/// Event to load additional products for pagination.
class LoadMoreProducts extends ProductEvent {
  final String? query; // Search query for filtering products.
  final String? categoryId; // ID of the category to filter products.
  final SortOption? sortOption; // Sorting criteria for products.

  const LoadMoreProducts({
    this.query,
    this.categoryId,
    this.sortOption,
  });

  @override
  List<Object?> get props => [query, categoryId, sortOption];
}