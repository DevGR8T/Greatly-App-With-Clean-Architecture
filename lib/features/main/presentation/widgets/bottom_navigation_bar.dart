import 'package:flutter/material.dart';

/// A custom bottom navigation bar widget.
/// 
/// This widget provides navigation between different sections of the app
/// using a `BottomNavigationBar`.
class CustomBottomNavigationBar extends StatelessWidget {
  /// The index of the currently selected tab.
  final int currentIndex;

  /// Callback function triggered when a tab is tapped.
  final Function(int) onTap;

  /// Constructor for the `CustomBottomNavigationBar`.
  /// 
  /// [currentIndex] is the index of the currently selected tab.
  /// [onTap] is the callback function triggered when a tab is tapped.
  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  /// Builds the bottom navigation bar widget.
  /// 
  /// The navigation bar includes four tabs: Home, Shop, Cart, and Profile.
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Highlight the selected tab
      onTap: onTap, // Trigger the callback when a tab is tapped
      type: BottomNavigationBarType.fixed, // Fixed navigation bar type
      selectedItemColor: Theme.of(context).primaryColor, // Color for the selected tab
      unselectedItemColor: Colors.grey, // Color for unselected tabs
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 0 ? Icons.home : Icons.home_outlined, // Switch between filled and outlined
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 1 ? Icons.shopping_bag : Icons.shopping_bag_outlined, // Switch between filled and outlined
          ),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 2 ? Icons.shopping_cart : Icons.shopping_cart_outlined, // Switch between filled and outlined
          ),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 3 ? Icons.person : Icons.person_outline, // Switch between filled and outlined
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}