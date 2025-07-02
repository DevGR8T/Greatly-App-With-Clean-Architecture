import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:greatly_user/core/theme/app_colors.dart';
import 'package:greatly_user/features/cart/presentation/pages/cart_page.dart';
import 'package:greatly_user/features/main/presentation/bloc/navigation_bloc.dart';
import 'package:greatly_user/features/home/presentation/pages/homepage.dart';
import 'package:greatly_user/features/main/presentation/bloc/navigation_event.dart';
import 'package:greatly_user/features/main/presentation/bloc/navigation_state.dart';
import 'package:greatly_user/features/main/presentation/widgets/bottom_navigation_bar.dart';
import 'package:greatly_user/features/products/presentation/pages/shop_page.dart';

import '../../../profile/presentation/pages/profile_page.dart';

/// The main page of the app that manages navigation between different tabs.
class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<NavigationBloc>(), // Use GetIt to retrieve NavigationBloc
      child: const MainView(),
    );
  }
}

/// The main view that displays the content and bottom navigation bar.
class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  // List of screens for each tab in the bottom navigation bar.
  final List<Widget> _screens = [
    const HomePage(), // Home page
    const ShopPage(showBackButton: false), // shop page
    const CartPage(), // Cart page
     const ProfilePage(), // Profile page
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          // Displays the current screen based on the selected tab.
          body: Stack(
            children: [
              // The screen content
              IndexedStack(
                index: state.currentIndex, // Current tab index
                children: _screens, // List of screens
              ),
              
              // Loading indicator overlay
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.surface,
                    ),
                  ),
                ),
            ],
          ),
          // Custom bottom navigation bar for tab navigation.
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: state.currentIndex, // Current tab index
            onTap: (index) {
              // Dispatch an event to navigate to the selected tab.
              context.read<NavigationBloc>().add(NavigateToTab(index));
            },
          ),
        );
      },
    );
  }
}