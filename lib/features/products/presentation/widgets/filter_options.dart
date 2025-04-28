import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Enum representing sorting options for products.
enum SortOption {
  newest,
  priceLowToHigh,
  priceHighToLow,
  rating
}

/// Extension to provide display names for each sorting option.
extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.newest:
        return 'Newest';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.rating:
        return 'Rating';
    }
  }
}

/// A widget to display filter options for sorting and toggling views.
class FilterOptions extends StatelessWidget {
  final SortOption selectedSortOption; // Currently selected sorting option
  final bool isGridView; // Whether the product view is in grid mode
  final Function(SortOption) onSortChanged; // Callback when a sorting option is selected

  const FilterOptions({
    Key? key,
    required this.selectedSortOption,
    required this.isGridView,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () => _showSortOptions(context), // Opens the sort options modal
        child: Icon(Icons.sort, size: 25, color: AppColors.onPrimary), // Sort icon
      ),
    );
  }

  /// Displays a bottom sheet with sorting options.
  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Rounded top corners
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(), // Closes the modal
                  ),
                ],
              ),
            ),
            Divider(height: 1), // Divider between header and options
            // List of sorting options
            Expanded(
              child: ListView.builder(
                itemCount: SortOption.values.length,
                itemBuilder: (context, index) {
                  final option = SortOption.values[index];
                  return RadioListTile<SortOption>(
                    title: Text(option.displayName), // Display name of the sort option
                    value: option, // Sort option value
                    groupValue: selectedSortOption, // Currently selected option
                    onChanged: (value) {
                      Navigator.of(context).pop(); // Close the modal
                      FocusScope.of(context).unfocus(); // Remove keyboard focus
                      if (value != null) onSortChanged(value); // Trigger callback
                    },
                    activeColor: AppColors.primary, // Highlight color for selected option
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}