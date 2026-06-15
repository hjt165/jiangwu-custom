import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/product.dart';

/// 首页产品卡片组件
/// 用于热门推荐横向列表

class HomeProductCard extends StatelessWidget {
  final Product? product;
  final VoidCallback? onTap;

  const HomeProductCard({
    super.key,
    this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: AppSizes.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作品图片
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: product?.coverImage != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusMedium),
                      ),
                      child: Image.network(
                        product!.coverImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: AppColors.textHint,
                      ),
                    ),
            ),
            // 作品信息
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.title ?? '加载中...',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.spacingXSmall),
                  Text(
                    product != null ? '¥${product!.minPrice ?? ''}起' : '¥--',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
