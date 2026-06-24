import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../common/image_widget.dart';
import '../common/app_card.dart';

/// 作品管理卡片组件
/// 展示手作人作品信息，支持上下架操作

class ProductManageCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProductManageCard({
    super.key,
    required this.product,
    this.onToggleStatus,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作品图片和信息
            Row(
              children: [
                // 作品封面
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: product.firstImage.isNotEmpty
                        ? ImageWidget(imageUrl: product.firstImage)
                        : Container(
                            color: AppColors.border,
                            child: const Icon(
                              Icons.image,
                              color: AppColors.textHint,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),

                // 作品详情
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.spacingSmall,
                              vertical: AppSizes.spacingXSmall,
                            ),
                            decoration: BoxDecoration(
                              color: product.isAvailable
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.textHint.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: Text(
                              product.isAvailable ? '上架中' : '已下架',
                              style: TextStyle(
                                fontSize: 11,
                                color: product.isAvailable
                                    ? AppColors.success
                                    : AppColors.textHint,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingXSmall),
                      Text(
                        product.category.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '¥${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                          Text(
                            '销量 ${product.orderCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // 操作按钮
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: '编辑',
                  onTap: onEdit,
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                _buildActionButton(
                  icon: product.isAvailable
                      ? Icons.visibility_off
                      : Icons.visibility,
                  label: product.isAvailable ? '下架' : '上架',
                  onTap: onToggleStatus,
                ),
                const SizedBox(width: AppSizes.spacingMedium),
                _buildActionButton(
                  icon: Icons.delete,
                  label: '删除',
                  color: AppColors.error,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? AppColors.textSecondary,
          ),
          const SizedBox(width: AppSizes.spacingXSmall),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
