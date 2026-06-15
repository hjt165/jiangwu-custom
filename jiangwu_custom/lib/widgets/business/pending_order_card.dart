import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../common/image_widget.dart';
import '../common/button_widget.dart';

/// 待处理订单卡片组件
/// 展示单个待处理订单信息，支持接受/拒绝操作

class PendingOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const PendingOrderCard({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: AppSizes.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单号和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '订单号: ${order.orderNo}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingSmall,
                    vertical: AppSizes.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: const Text(
                    '待接单',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // 商品信息
            Row(
              children: [
                // 商品图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: order.product?.firstImage != null
                        ? ImageWidget(imageUrl: order.product!.firstImage!)
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

                // 商品详情
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.product?.title ?? '未知商品',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.spacingXSmall),
                      if (order.customization != null) ...[
                        Text(
                          '材质: ${order.customization!.material}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingXSmall),
                      ],
                      Text(
                        '金额: ¥${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
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
                Expanded(
                  child: ButtonWidget(
                    text: '拒绝',
                    isOutlined: true,
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: ButtonWidget(
                    text: '接受',
                    onPressed: onAccept,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
