import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/features/products/domain/entities/category.dart';
import 'package:greatly_user/features/products/presentation/widgets/category_list_widget.dart';
import 'package:greatly_user/features/products/presentation/widgets/filter_options.dart';
import 'package:greatly_user/features/products/presentation/widgets/product_grid_view.dart';
import 'package:greatly_user/features/products/presentation/widgets/searchbar_widget.dart';
import 'package:greatly_user/shared/components/error_state.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'product_detail_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key, this.showBackButton =false}) : super(key: key);
  // Add a parameter to track navigation source
  final bool showBackButton;
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Category? _selectedCategory;
  String? _searchQuery;
  SortOption? _sortOption;
  final ScrollController _scrollController = ScrollController();
  bool _isGridView = true;
  


  @override
  void initState() {
    super.initState();
    // Trigger the GetCategories event when the page is initialized.
    context.read<CategoryBloc>().add(GetCategories());
    // Trigger the GetProducts event when the page is initialized.
    context.read<ProductBloc>().add(GetProducts());

    // Add scroll listener to handle pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if we're near the bottom of the list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductLoaded && !state.isLoading && state.hasMore) {
        // Load more products when we're near the end
        context.read<ProductBloc>().add(LoadMoreProducts(
              query: _searchQuery,
              categoryId: _selectedCategory?.id,
              sortOption: _sortOption,
            ));
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        elevation: 0,
        centerTitle: true,
        // Show back button conditionally based on navigation source
        automaticallyImplyLeading: widget.showBackButton,
           // If we're showing a back button, no need for filter on left side
        // Otherwise show filter options as leading widget
        leading: widget.showBackButton ? null : _buildFilterOptions(),
        // If showing back button, move filter options to actions
        actions: widget.showBackButton ? [_buildFilterOptions()] : null,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
              child:
                  _buildProductList()), // Add the product list below the category filter.
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SearchBarWidget(
        onSearch: (query) {
          setState(() {
            _searchQuery = query;
          });
          // Reset pagination and fetch products with the new query
          context.read<ProductBloc>().add(GetProducts(
                query: query,
                categoryId: _selectedCategory?.id,
                sortOption: _sortOption,
              ));
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CategoryList(
              categories: state.categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
                // Trigger product fetching based on the selected category.
                context.read<ProductBloc>().add(GetProducts(
                      query: _searchQuery,
                      categoryId: _selectedCategory?.id,
                      sortOption: _sortOption,
                    ));
              },
            ),
          );
        }
        if (state is CategoryError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to load categories: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildFilterOptions() {
    return FilterOptions(
      selectedSortOption: _sortOption ?? SortOption.newest,
      isGridView: _isGridView,
      onSortChanged: (option) {
        setState(() {
          _sortOption = option;
        });
        context.read<ProductBloc>().add(GetProducts(
              query: _searchQuery,
              categoryId: _selectedCategory?.id,
              sortOption: option,
            ));
      },
    );
  }

Widget _buildProductList() {
  return RefreshIndicator(
    onRefresh: () async {
      // Trigger product fetching to refresh the list
      context.read<ProductBloc>().add(GetProducts(
            query: _searchQuery,
            categoryId: _selectedCategory?.id,
            sortOption: _sortOption,
          ));
    },
    child: BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProductError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: () => context.read<ProductBloc>().add(GetProducts(
                  query: _searchQuery,
                  categoryId: _selectedCategory?.id,
                  sortOption: _sortOption,
                )),
          );
        }
        if (state is ProductLoaded) {
          return ProductGridView(
            products: state.products,
            isLoading: state.isLoading,
            scrollController: _scrollController,
            onProductSelected: (product) {


              
              // Dismiss the keyboard using FocusScope
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailPage(productId: product.id),
                ),
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    ),
  );
}
}
