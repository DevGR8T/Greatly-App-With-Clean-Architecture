import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/config/routes/routes.dart';
import 'package:greatly_user/core/constants/strings.dart';
import 'package:greatly_user/features/products/presentation/pages/product_detail_page.dart';
import 'package:greatly_user/features/products/presentation/pages/shop_page.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/components/error_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/featured_products_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Track loading status
  bool _isLoading = true;
  
  // Track states
  HomeState? _bannersState;
  HomeState? _productsState;
  
  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when the page is initialized
  }

  /// Loads data for banners and featured products.
  void _loadData() {
    setState(() {
      _isLoading = true;
      _bannersState = null;
      _productsState = null;
    });
    
    // Dispatch events to load banners and featured products
    context.read<HomeBloc>().add(GetBannersEvent());
    context.read<HomeBloc>().add(GetFeaturedProductsEvent());
  }
  
  /// Update the state and check if loading is complete
  void _updateState(HomeState state) {
    if (state is BannersLoaded || state is BannersError) {
      setState(() {
        _bannersState = state;
      });
    } else if (state is FeaturedProductsLoaded || state is FeaturedProductsError) {
      setState(() {
        _productsState = state;
      });
    }
    
    // Check if both have loaded (success or error)
    if (_bannersState != null && _productsState != null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        _updateState(state);
      },
      child: Scaffold(
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  _loadData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBannerSection(),
                      const SizedBox(height: 15),
                      const SizedBox(height: 5),
                      _buildFeaturedProductsSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Builds the banner section of the homepage.
  Widget _buildBannerSection() {
    if (_bannersState is BannersLoaded) {
      // Show the banner carousel when banners are loaded
      return BannerCarousel(banners: (_bannersState as BannersLoaded).banners);
    } else if (_bannersState is BannersError) {
      // Show an error message if loading banners fails
      return SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ErrorStateWidget(
            message: (_bannersState as BannersError).message,
            onRetry: () {
              setState(() {
                _bannersState = null;
                _isLoading = _productsState == null;
              });
              context.read<HomeBloc>().add(GetBannersEvent());
            },
          ),
        ),
      );
    }
    
    // Default fallback (shouldn't happen in normal use)
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.50,
      child: const Center(
        child: SizedBox(),
      ),
    );
  }

  /// Builds the header for the featured products section.
  Widget _buildFeaturedProductsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Featured Products',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
             // Pass showBackButton: true when navigating from View All button
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ShopPage(showBackButton: true),
              ),
            );
            },
            child: const Text(
              'View All',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the featured products section of the homepage.
  Widget _buildFeaturedProductsSection() {
    if (_productsState is FeaturedProductsLoaded) {
      // Show the grid of featured products when loaded
      return Column(
        children: [
          _buildFeaturedProductsHeader(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.33,
            child: FeaturedProductsGrid(
              products: (_productsState as FeaturedProductsLoaded).products,
              onProductSelected: (productId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailPage(productId: productId),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (_productsState is FeaturedProductsError) {
      // Show an error message if loading featured products fails
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ErrorStateWidget(
            message: (_productsState as FeaturedProductsError).message,
            onRetry: () {
              setState(() {
                _productsState = null;
                _isLoading = _bannersState == null;
              });
              context.read<HomeBloc>().add(GetFeaturedProductsEvent());
            },
          ),
        ),
      );
    }
    
    // Default fallback (shouldn't happen in normal use)
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: const Center(
        child: SizedBox(),
      ),
    );
  }
}