import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../common/app_card.dart';

/// 订单信息卡片组件
/// 展示产品信息、手作人信息、定制参数

class OrderInfoCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onContactArtisan;

  const OrderInfoCard({
    super.key,
    required this.order,
    this.onContactArtisan,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 产品信息
          _buildProductInfo(),
          const Divider(height: AppSizes.paddingLarge),

          // 手作人信息
          if (order.artisan != null) ...[
            _buildArtisanInfo(),
            const Divider(height: AppSizes.paddingLarge),
          ],

          // 定制参数
          if (order.customization != null) _buildCustomizationInfo(),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 产品图片
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            color: AppColors.background,
          ),
          child: order.product?.images.isNotEmpty == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  child: Image.network(
                    order.product!.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image,
                        size: 40,
                        color: AppColors.textHint,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.image,
                  size: 40,
                  color: AppColors.textHint,
                ),
        ),
        const SizedBox(width: AppSizes.paddingMedium),

        // 产品详情
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.product?.title ?? '定制作品',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              if (order.product?.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.product!.category.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                '¥${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArtisanInfo() {
    final artisan = order.artisan!;
    return Row(
      children: [
        // 手作人头像
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
          ),
          child: artisan.avatar != null && artisan.avatar!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    artisan.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 24,
                        color: AppColors.textHint,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.person,
                  size: 24,
                  color: AppColors.textHint,
                ),
        ),
        const SizedBox(width: AppSizes.paddingMedium),

        // 手作人信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    artisan.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (artisan.isVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                artisan.specialty ?? artisan.ratingText,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // 联系按钮
        IconButton(
          onPressed: onContactArtisan,
          icon: const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizationInfo() {
    final customization = order.customization!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.tune,
              size: 18,
              color: AppColors.primary,
            ),
            SizedBox(width: AppSizes.spacingSmall),
            Text(
              '定制参数',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingSmall),

        // 材质
        if (customization.material.isNotEmpty)
          _buildParameterRow('材质', customization.material),

        // 尺寸
        if (customization.size.isNotEmpty)
          _buildParameterRow('尺寸', customization.size),

        // 颜色
        if (customization.color.isNotEmpty)
          _buildParameterRow('颜色', customization.color),

        // 雕刻内容
        if (customization.engraving.isNotEmpty)
          _buildParameterRow('雕刻', customization.engraving),

        // 参考图片
        if (customization.referenceImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.spacingSmall),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: customization.referenceImages.take(3).map((imageUrl) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildParameterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
