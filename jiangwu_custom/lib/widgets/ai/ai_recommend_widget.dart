import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// AI推荐结果展示组件
/// 展示手作人推荐或方案推荐结果

class AiRecommendWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>)? onItemClick;
  final String emptyText;

  const AiRecommendWidget({
    super.key,
    required this.title,
    required this.items,
    this.onItemClick,
    this.emptyText = '暂无推荐',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppSizes.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.spacingMedium),
            if (items.isEmpty)
              _buildEmpty()
            else
              _buildList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.recommend, color: AppColors.accent, size: 24),
        const SizedBox(width: AppSizes.spacingSmall),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingSmall,
            vertical: AppSizes.spacingXSmall,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Text(
            '${items.length}个结果',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingLarge),
        child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          Text(
            emptyText,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: items.map((item) {
        return _buildItem(item);
      }).toList(),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final name = item['name'] ?? item['title'] ?? '';
    final avatar = item['avatar'] ?? item['coverImage'];
    final matchScore = item['matchScore'] ?? item['match_score'];
    final matchReason = item['matchReason'] ?? item['match_reason'];
    final rating = item['rating'];
    final price = item['estimatedPrice'] ?? item['estimated_price'];
    final days = item['estimatedDays'] ?? item['estimated_days'];

    return InkWell(
      onTap: onItemClick != null ? () => onItemClick!(item) : null,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacingMedium),
        margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像/封面
            if (avatar != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                child: Image.network(
                  avatar,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: AppColors.border,
                      child: Icon(Icons.image, color: AppColors.textHint),
                    );
                  },
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Icon(Icons.person, color: AppColors.accent),
              ),
            const SizedBox(width: AppSizes.spacingMedium),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (matchScore != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.spacingSmall,
                            vertical: AppSizes.spacingXSmall,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Text(
                            '${(matchScore * 100).toStringAsFixed(0)}%匹配',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (rating != null) ...[
                    const SizedBox(height: AppSizes.spacingXSmall),
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.warning, size: 16),
                        const SizedBox(width: AppSizes.spacingXSmall),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (price != null || days != null) ...[
                    const SizedBox(height: AppSizes.spacingXSmall),
                    Row(
                      children: [
                        if (price != null) ...[
                          Text(
                            '¥${price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (days != null) ...[
                            const SizedBox(width: AppSizes.spacingMedium),
                            Text(
                              '${days}天交付',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ],
                  if (matchReason != null) ...[
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      matchReason,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
