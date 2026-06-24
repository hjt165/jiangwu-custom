import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../../utils/date_utils.dart';
import '../../models/review.dart';
import '../common/empty_widget.dart';
import '../common/image_widget.dart';

/// 手作人评价列表组件
/// 展示用户评价：评分、内容、标签、时间

class ArtisanReviewsList extends StatelessWidget {
  final List<Review> reviews;
  final double averageRating;
  final int totalReviews;

  const ArtisanReviewsList({
    super.key,
    required this.reviews,
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const EmptyWidget(
        icon: Icons.rate_review_outlined,
        message: '暂无评价',
      );
    }

    return Column(
      children: [
        // 评价统计头部
        _buildRatingSummary(),
        const Divider(height: 1),
        // 评价列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewItem(review);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      color: AppColors.background,
      child: Row(
        children: [
          // 平均评分
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < averageRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 16,
                    color: AppColors.warning,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews条评价',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.paddingLarge),
          // 评分分布（简化版）
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.6),
                _buildRatingBar(4, 0.25),
                _buildRatingBar(3, 0.1),
                _buildRatingBar(2, 0.03),
                _buildRatingBar(1, 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.star, size: 12, color: AppColors.warning),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${(percentage * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息和评分
          Row(
            children: [
              // 用户头像
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.background,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0]
                      : '匿名',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              // 用户名
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : '匿名用户',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppDateUtils.formatYMDHM(review.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              // 评分
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 14,
                    color: AppColors.warning,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          // 评价内容
          if (review.content.isNotEmpty)
            Text(
              review.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          // 评价标签
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingSmall),
            Wrap(
              spacing: AppSizes.spacingSmall,
              runSpacing: AppSizes.spacingSmall,
              children: review.tags.map((tag) {
                // 判断是正面还是负面标签
                final isPositive = ReviewTags.positive.contains(tag);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPositive
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          // 评价图片
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingSmall),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSizes.spacingSmall),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageWidget(
                        imageUrl: review.images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

}
