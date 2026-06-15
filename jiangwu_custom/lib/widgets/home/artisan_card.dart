import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/artisan.dart';

/// 首页手作人卡片组件
/// 用于手作人推荐横向列表

class HomeArtisanCard extends StatelessWidget {
  final Artisan? artisan;
  final VoidCallback? onTap;

  const HomeArtisanCard({
    super.key,
    this.artisan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: AppSizes.spacingMedium),
        child: Column(
          children: [
            // 头像
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: artisan?.avatar != null
                  ? ClipOval(
                      child: Image.network(
                        artisan!.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.textHint,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.textHint,
                    ),
            ),
            const SizedBox(height: AppSizes.spacingSmall),
            // 名称
            Text(
              artisan?.name ?? '加载中...',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.spacingXSmall),
            // 评分
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  size: 12,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 2),
                Text(
                  artisan != null ? artisan!.rating.toStringAsFixed(1) : '--',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
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
