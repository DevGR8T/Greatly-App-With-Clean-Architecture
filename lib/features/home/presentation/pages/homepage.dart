import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/components/error_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/featured_products_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _initialLoading = true; // Tracks whether the initial loading is in progress

  @override
  void initState() {
    super.initState();
    _loadData(initialLoad: true); // Load data when the page is initialized
  }

  /// Loads data for banners and featured products.
  /// 
  /// [initialLoad] determines whether this is the first load or a refresh.
  Future<void> _loadData({bool initialLoad = false}) async {
    if (initialLoad) {
      setState(() {
        _initialLoading = true; // Show loading spinner during the initial load
      });
    }

    // Dispatch events to load banners and featured products
    context.read<HomeBloc>().add(GetBannersEvent());
    context.read<HomeBloc>().add(GetFeaturedProductsEvent());
    
    if (initialLoad) {
      // Wait for both to complete on initial load
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _initialLoading = false; // Hide loading spinner after the initial load
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show a spinner during the initial load
            )
          : RefreshIndicator(
              onRefresh: () => _loadData(initialLoad: false), // Reload data on pull-to-refresh
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerSection(), // Build the banner section
                    const SizedBox(height: 15),
                    _buildFeaturedProductsHeader(), // Build the header for featured products
                    const SizedBox(height: 5),
                    _buildFeaturedProductsSection(), // Build the featured products section
                  ],
                ),
              ),
            ),
    );
  }

  /// Builds the banner section of the homepage.
  /// 
  /// Displays a loading spinner, the banner carousel, or an error message based on the state.
  Widget _buildBannerSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          current is BannersLoading || current is BannersLoaded || current is BannersError,
      builder: (context, state) {
        if (state is BannersLoading) {
          // Show a loading spinner while banners are loading
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.50,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is BannersLoaded) {
          // Show the banner carousel when banners are loaded
          return BannerCarousel(banners: state.banners);
        } else if (state is BannersError) {
          // Show an error message if loading banners fails
          return SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ErrorState(
                message: state.message,
                onRetry: () {
                  context.read<HomeBloc>().add(GetBannersEvent()); // Retry loading banners
                },
              ),
            ),
          );
        }
        // Default fallback to a loading spinner
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  /// Builds the header for the featured products section.
  /// 
  /// Displays a title ("Featured Products") and a "View All" button.
  Widget _buildFeaturedProductsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between the text and button
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
              // Handle "View All" button press
            },
            child: const Text(
              'View All',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary, // Customize the color if needed
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the featured products section of the homepage.
  /// 
  /// Displays a loading spinner, the featured products grid, or an error message based on the state.
  Widget _buildFeaturedProductsSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) =>
          current is FeaturedProductsLoading || 
          current is FeaturedProductsLoaded || 
          current is FeaturedProductsError,
      builder: (context, state) {
        if (state is FeaturedProductsLoading) {
          // Show a loading spinner while featured products are loading
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is FeaturedProductsLoaded) {
          // Show the grid of featured products when loaded
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.33,
            child: FeaturedProductsGrid(products: state.products),
          );
        } else if (state is FeaturedProductsError) {
          // Show an error message if loading featured products fails
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ErrorState(
                message: state.message,
                onRetry: () {
                  context.read<HomeBloc>().add(GetFeaturedProductsEvent()); // Retry loading products
                },
              ),
            ),
          );
        }
        // Default fallback to a loading spinner
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}