import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../business/filter_sort_sheet.dart';

/// 搜索筛选标签栏组件
class SearchFilterBar extends StatelessWidget {
  final FilterSortOptions filterOptions;
  final int resultCount;
  final ValueChanged<FilterSortOptions> onFilterChanged;
  final VoidCallback onShowFilterSheet;

  const SearchFilterBar({
    super.key,
    required this.filterOptions,
    required this.resultCount,
    required this.onFilterChanged,
    required this.onShowFilterSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      color: AppColors.white,
      child: Row(
        children: [
          if (filterOptions.category != null)
            _buildFilterTag(
              label: filterOptions.category!.label,
              onRemove: () => onFilterChanged(
                filterOptions.copyWith(clearCategory: true),
              ),
            ),
          if (filterOptions.minPrice != null || filterOptions.maxPrice != null)
            _buildFilterTag(
              label: '¥${filterOptions.minPrice ?? 0}~${filterOptions.maxPrice ?? "∞"}',
              onRemove: () => onFilterChanged(
                filterOptions.copyWith(clearPrice: true),
              ),
            ),
          Expanded(
            child: Text(
              '共${resultCount}件作品',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ),
          GestureDetector(
            onTap: onShowFilterSheet,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filterOptions.sortType.label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag({required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: AppSizes.spacingSmall),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
