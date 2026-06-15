import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 星级评分组件
/// 支持0.5星精度评分，显示评分文字

class RatingSelector extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double maxRating;
  final double itemSize;

  const RatingSelector({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxRating = 5,
    this.itemSize = 36,
  });

  String get _ratingText {
    if (rating >= 4.5) return '非常满意';
    if (rating >= 4.0) return '满意';
    if (rating >= 3.0) return '一般';
    if (rating >= 2.0) return '不满意';
    if (rating > 0) return '非常不满意';
    return '请评分';
  }

  Color get _ratingColor {
    if (rating >= 4.0) return AppColors.success;
    if (rating >= 3.0) return AppColors.accent;
    if (rating > 0) return AppColors.error;
    return AppColors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 星星评分
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate((maxRating * 2).toInt(), (index) {
            final starIndex = index ~/ 2;
            final isHalf = index % 2 == 1;
            final starValue = starIndex + (isHalf ? 0.5 : 1.0);
            final isSelected = rating >= starValue;
            final isHalfSelected = rating >= starValue && rating < starValue + 0.5 && isHalf;

            return GestureDetector(
              onTap: () => onRatingChanged(starValue),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: itemSize,
                  color: isSelected || isHalfSelected
                      ? Colors.amber
                      : AppColors.textHint,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        // 评分文字
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _ratingColor,
          ),
          child: Text(_ratingText),
        ),
      ],
    );
  }
}
