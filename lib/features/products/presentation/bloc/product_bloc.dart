import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/features/products/presentation/widgets/filter_options.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
  }) : super(ProductInitial()) {
    on<GetProducts>(_onGetProducts);
    on<GetProductById>(_onGetProductById);
    on<LoadMoreProducts>(_onLoadMoreProducts);
  }

  Future<void> _onGetProducts(
    GetProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductInitial());

    print('Getting products with sort option: ${event.sortOption?.name}');

    final backendSortOption = event.sortOption?.name == 'rating' 
        ? 'createdAt:desc'
        : event.sortOption?.name;

    final params = GetProductsParams(
      query: event.query,
      categoryId: event.categoryId,
      sortOption: backendSortOption,
      page: 1,
      refresh: event.refresh,
    );

    final result = await getProductsUseCase(params);

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (productData) {
        List<Product> products = List<Product>.from(productData.products);

        if (event.sortOption?.name == 'rating') {
          products.sort((a, b) {
            double aRating = a.rating > 0 ? a.rating : double.negativeInfinity;
            double bRating = b.rating > 0 ? b.rating : double.negativeInfinity;
            int ratingCompare = bRating.compareTo(aRating);
            if (ratingCompare != 0) return ratingCompare;
            return a.name.compareTo(b.name);
          });

          print('Products after sorting by rating:');
          for (var product in products) {
            print('${product.name}: Rating = ${product.rating}');
          }
        }

        emit(ProductLoaded(
          products: products,
          hasMore: productData.hasMore,
          page: 1,
        ));
      },
    );
  }

  Future<void> _onGetProductById(
    GetProductById event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductInitial());

    final result = await getProductByIdUseCase(event.id);

    return result.fold(
      (failure) {
        emit(ProductError(failure.message));
      },
      (product) async {
        try {
          final categoryParams = GetProductsParams(
            categoryId: product.category.id,
            page: 1,
          );

          final categoryResult = await getProductsUseCase(categoryParams);

          categoryResult.fold(
            (failure) {
              emit(ProductLoaded(
                products: [],
                selectedProduct: product,
                hasMore: false,
              ));
            },
            (productData) {
              final filteredProducts = productData.products
                  .where((p) => p.id != product.id)
                  .toList();

              filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));

              emit(ProductLoaded(
                products: filteredProducts,
                selectedProduct: product,
                hasMore: productData.hasMore,
                page: 1,
              ));
            },
          );
        } catch (e) {
          emit(ProductLoaded(
            products: [],
            selectedProduct: product,
            hasMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProductLoaded && !currentState.isLoading && currentState.hasMore) {
      emit(currentState.copyWith(isLoading: true));

      final nextPage = currentState.page + 1;

      final backendSortOption = event.sortOption?.name == 'rating' 
          ? 'createdAt:desc'
          : event.sortOption?.name;

      final params = GetProductsParams(
        query: event.query,
        categoryId: event.categoryId,
        sortOption: backendSortOption,
        page: nextPage,
      );

      final result = await getProductsUseCase(params);
      result.fold(
        (failure) => emit(ProductError(failure.message)),
        (productData) {
          List<Product> allProducts = List<Product>.from(currentState.products);
          allProducts.addAll(productData.products);

          if (event.sortOption?.name == 'rating') {
            allProducts.sort((a, b) {
              double aRating = a.rating > 0 ? a.rating : double.negativeInfinity;
              double bRating = b.rating > 0 ? b.rating : double.negativeInfinity;
              int ratingCompare = bRating.compareTo(aRating);
              if (ratingCompare != 0) return ratingCompare;
              return a.name.compareTo(b.name);
            });
          }

          emit(ProductLoaded(
            products: allProducts,
            selectedProduct: currentState.selectedProduct,
            hasMore: productData.hasMore,
            page: nextPage,
            isLoading: false,
          ));
        },
      );
    }
  }
}