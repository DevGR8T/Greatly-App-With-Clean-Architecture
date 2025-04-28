// lib/features/product/presentation/widgets/category_filter_chip.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';

class CategoryFilterChip extends StatelessWidget {
  final Category? category;
  final bool isSelected;
  final VoidCallback onSelected;

  const CategoryFilterChip({
    Key? key,
    this.category,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: FilterChip(
          selected: isSelected,
          label: Text(category?.name ?? 'All'),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.grey[200],
          selectedColor: AppColors.primary,
          onSelected: (_) => onSelected(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          elevation: 0,
          pressElevation: 2,
          side: BorderSide.none,
          checkmarkColor: AppColors.onPrimary,
          showCheckmark: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}