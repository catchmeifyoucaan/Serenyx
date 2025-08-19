import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MarketplaceFilter extends StatelessWidget {
  final String selectedCategory;
  final String selectedFilter;
  final Function(String) onCategoryChanged;
  final Function(String) onFilterChanged;

  const MarketplaceFilter({
    super.key,
    required this.selectedCategory,
    required this.selectedFilter,
    required this.onCategoryChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.colors.outline),
        ),
      ),
      child: Column(
        children: [
          // Category Filter
          Row(
            children: [
              Text(
                'Category:',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', selectedCategory == 'All'),
                      _buildCategoryChip('Grooming', selectedCategory == 'Grooming'),
                      _buildCategoryChip('Training', selectedCategory == 'Training'),
                      _buildCategoryChip('Care', selectedCategory == 'Care'),
                      _buildCategoryChip('Health', selectedCategory == 'Health'),
                      _buildCategoryChip('Toys', selectedCategory == 'Toys'),
                      _buildCategoryChip('Food', selectedCategory == 'Food'),
                      _buildCategoryChip('Beds', selectedCategory == 'Beds'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sort/Filter Options
          Row(
            children: [
              Text(
                'Sort by:',
                style: AppTheme.textStyles.bodyMedium?.copyWith(
                  color: AppTheme.colors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Recommended', selectedFilter == 'Recommended'),
                      _buildFilterChip('Top Rated', selectedFilter == 'Top Rated'),
                      _buildFilterChip('Nearest', selectedFilter == 'Nearest'),
                      _buildFilterChip('On Sale', selectedFilter == 'On Sale'),
                      _buildFilterChip('Price: Low to High', selectedFilter == 'Price: Low to High'),
                      _buildFilterChip('Price: High to Low', selectedFilter == 'Price: High to Low'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppTheme.colors.textPrimary,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          onCategoryChanged(label);
        },
        backgroundColor: AppTheme.colors.surface,
        selectedColor: AppTheme.colors.primary,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppTheme.colors.primary : AppTheme.colors.outline,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: AppTheme.textStyles.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppTheme.colors.textPrimary,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          onFilterChanged(label);
        },
        backgroundColor: AppTheme.colors.surface,
        selectedColor: AppTheme.colors.secondary,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppTheme.colors.secondary : AppTheme.colors.outline,
        ),
      ),
    );
  }
}// Marketplace Filter Widget
