import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 热门搜索标签组件
class HotSearchTags extends StatelessWidget {
  final List<String> hotSearches;
  final ValueChanged<String> onTagTap;

  const HotSearchTags({
    super.key,
    required this.hotSearches,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.trending_up,
              size: 18,
              color: AppColors.error,
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Text(
              '热门搜索',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Wrap(
          spacing: AppSizes.spacingSmall,
          runSpacing: AppSizes.spacingSmall,
          children: hotSearches.map((tag) {
            return GestureDetector(
              onTap: () => onTagTap(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
