import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

/// Bloc to handle product-related events and manage states.
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase; // Fetches a list of products.
  final GetProductByIdUseCase getProductByIdUseCase; // Fetches a single product by ID.

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
  }) : super(ProductInitial()) {
    on<GetProducts>(_onGetProducts); // Handles fetching products.
    on<GetProductById>(_onGetProductById); // Handles fetching a single product.
    on<LoadMoreProducts>(_onLoadMoreProducts); // Handles pagination for products.
  }

  /// Fetches products based on query, category, and sort options.
  Future<void> _onGetProducts(
    GetProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductInitial()); // Show loading state.

    final params = GetProductsParams(
      query: event.query,
      categoryId: event.categoryId,
      sortOption: event.sortOption?.name,
      page: 1,
      refresh: event.refresh,
    );

    final result = await getProductsUseCase(params);
    result.fold(
      (failure) => emit(ProductError(failure.message)), // Show error state.
      (productData) => emit(ProductLoaded(
        products: productData.products,
        hasMore: productData.hasMore,
        page: 1,
      )), // Show loaded state with products.
    );
  }

  /// Fetches a single product by its ID.
Future<void> _onGetProductById(
  GetProductById event,
  Emitter<ProductState> emit,
) async {
  emit(ProductInitial()); // Show loading state.

  // First get the product details
  final result = await getProductByIdUseCase(event.id);
  
  // Handle product result
  return result.fold(
    (failure) {
      // In case of failure, emit error state and finish
      emit(ProductError(failure.message));
    },
    (product) async {
      // We found the product, now get related products
      // Important: we must handle this within the fold for proper async behavior
      
      try {
        final categoryParams = GetProductsParams(
          categoryId: product.category.id,
          page: 1,
        );
        
        final categoryResult = await getProductsUseCase(categoryParams);
        
        // Handle the result of fetching related products
        categoryResult.fold(
          (failure) {
            // If we can't get similar products, still show the main product
            emit(ProductLoaded(
              products: [],
              selectedProduct: product,
              hasMore: false,
            ));
          },
          (productData) {
            // Filter out the current product from the list
            final filteredProducts = productData.products
                .where((p) => p.id != product.id)
                .toList();
                
            emit(ProductLoaded(
              products: filteredProducts,
              selectedProduct: product,
              hasMore: productData.hasMore,
              page: 1,
            ));
          },
        );
      } catch (e) {
        // In case of exception, still show the main product
        emit(ProductLoaded(
          products: [],
          selectedProduct: product,
          hasMore: false,
        ));
      }
    },
  );
}
  /// Loads more products for pagination.
  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProductLoaded && !currentState.isLoading && currentState.hasMore) {
      emit(currentState.copyWith(isLoading: true)); // Show loading state for pagination.

      final nextPage = currentState.page + 1;
      final params = GetProductsParams(
        query: event.query,
        categoryId: event.categoryId,
        sortOption: event.sortOption?.name,
        page: nextPage,
      );

      final result = await getProductsUseCase(params);
      result.fold(
        (failure) => emit(ProductError(failure.message)), // Show error state.
        (productData) {
          final updatedProducts = List<Product>.from(currentState.products)
            ..addAll(productData.products);

          emit(ProductLoaded(
            products: updatedProducts,
            selectedProduct: currentState.selectedProduct,
            hasMore: productData.hasMore,
            page: nextPage,
            isLoading: false,
          )); // Show updated loaded state with more products.
        },
      );
    }
  }
}