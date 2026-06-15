import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/review.dart';

/// 标签选择组件
/// 根据评分动态显示好评/差评标签，支持多选

class TagSelector extends StatelessWidget {
  final double rating;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagSelector({
    super.key,
    required this.rating,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = rating >= 4;
    final tags = isPositive ? ReviewTags.positive : ReviewTags.negative;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPositive ? '好评标签（可多选）' : '差评标签（可多选）',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => _toggleTag(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isPositive ? AppColors.success : AppColors.accent)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(
                    color: isSelected
                        ? (isPositive ? AppColors.success : AppColors.accent)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _toggleTag(String tag) {
    final newTags = List<String>.from(selectedTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    onTagsChanged(newTags);
  }
}
