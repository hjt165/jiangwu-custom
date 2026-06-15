import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../common/image_widget.dart';
import '../common/empty_widget.dart';

/// 作品网格组件
/// 2列网格布局，展示作品封面、标题、价格

class ArtisanWorksGrid extends StatelessWidget {
  final List<Product> works;
  final ValueChanged<Product>? onWorkTap;

  const ArtisanWorksGrid({
    super.key,
    required this.works,
    this.onWorkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return const EmptyWidget(
        icon: Icons.inventory_2_outlined,
        message: '暂无作品',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppSizes.spacingMedium,
        mainAxisSpacing: AppSizes.spacingMedium,
      ),
      itemCount: works.length,
      itemBuilder: (context, index) {
        final work = works[index];
        return _buildWorkCard(work);
      },
    );
  }

  Widget _buildWorkCard(Product work) {
    return GestureDetector(
      onTap: () => onWorkTap?.call(work),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: AppSizes.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作品封面
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusMedium),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageWidget(
                      imageUrl: work.firstImage,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // 精选标签
                    if (work.isFeatured)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '精选',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // 折扣标签
                    if (work.hasDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${work.discountPercent}%OFF',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 作品信息
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      work.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // 分类标签
                    if (work.category != ProductCategory.other)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          work.category.label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    // 价格
                    Row(
                      children: [
                        Text(
                          '¥${work.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (work.hasDiscount && work.originalPrice != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '¥${work.originalPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
