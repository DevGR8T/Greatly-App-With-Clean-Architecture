import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import 'category_filter_chip.dart';

/// Displays a horizontal list of categories as filter chips.
class CategoryList extends StatelessWidget {
  final List<Category> categories; // List of categories to display.
  final Category? selectedCategory; // Currently selected category.
  final Function(Category?) onCategorySelected; // Callback for category selection.

  const CategoryList({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // Fixed height for the category list.
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Horizontal scrolling.
        itemCount: categories.length + 1, // +1 for the "All" option.
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" category filter chip.
            return CategoryFilterChip(
              category: null,
              isSelected: selectedCategory == null, // Selected if no category is selected.
              onSelected: () => onCategorySelected(null), // Callback for "All" selection.
            );
          }

          // Individual category filter chip.
          final category = categories[index - 1];
          return CategoryFilterChip(
            category: category,
            isSelected: selectedCategory?.id == category.id, // Check if the category is selected.
            onSelected: () => onCategorySelected(category), // Callback for category selection.
          );
        },
      ),
    );
  }
}