import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/order.dart';

/// 交付内容展示组件
/// 展示手作人提交的交付图片和备注

class StageDeliverCard extends StatelessWidget {
  final OrderStage stage;

  const StageDeliverCard({
    super.key,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
              const Text(
                '交付内容',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // 交付图片
          if (stage.deliverImages.isNotEmpty) ...[
            Text(
              '交付图片 (${stage.deliverImages.length}张)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            // 只读模式展示图片
            _buildImagePreview(stage.deliverImages),
            const SizedBox(height: AppSizes.paddingMedium),
          ],

          // 交付备注
          if (stage.deliverNote != null && stage.deliverNote!.isNotEmpty) ...[
            Text(
              '交付备注',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Text(
                stage.deliverNote!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],

          // 无内容提示
          if (stage.deliverImages.isEmpty &&
              (stage.deliverNote == null || stage.deliverNote!.isEmpty))
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                child: Text(
                  '暂无交付内容',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(List<String> images) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: images.take(9).map((imageUrl) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
