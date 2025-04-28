import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

/// Defines the various states for product-related operations.
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// State when no product-related action has occurred yet.
class ProductInitial extends ProductState {}

/// State when products are successfully loaded.
class ProductLoaded extends ProductState {
  final List<Product> products; // List of loaded products.
  final Product? selectedProduct; // Currently selected product.
  final bool isLoading; // Indicates if more products are being loaded.
  final bool hasMore; // Indicates if more products are available for pagination.
  final int page; // Current page number.

  const ProductLoaded({
    required this.products,
    this.selectedProduct,
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
  });

  /// Creates a new state with updated values while retaining existing ones.
  ProductLoaded copyWith({
    List<Product>? products,
    Product? selectedProduct,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [products, selectedProduct, isLoading, hasMore, page];
}

/// State when an error occurs during product-related operations.
class ProductError extends ProductState {
  final String message; // Error message.

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}