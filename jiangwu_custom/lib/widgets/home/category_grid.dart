import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 首页分类网格组件
/// 展示工艺品类入口

class CategoryGrid extends StatelessWidget {
  final Function(String code, String name)? onCategoryTap;

  const CategoryGrid({
    super.key,
    this.onCategoryTap,
  });

  static const List<Map<String, dynamic>> _categories = [
    {'icon': Icons.checkroom, 'name': '首饰', 'code': 'jewelry'},
    {'icon': Icons.category, 'name': '皮具', 'code': 'leather'},
    {'icon': Icons.brush, 'name': '陶瓷', 'code': 'ceramic'},
    {'icon': Icons.texture, 'name': '木艺', 'code': 'woodwork'},
    {'icon': Icons.palette, 'name': '绘画', 'code': 'painting'},
    {'icon': Icons.more_horiz, 'name': '其他', 'code': 'other'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '工艺分类',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSizes.spacingMedium,
              crossAxisSpacing: AppSizes.spacingMedium,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryItem(
                context,
                icon: category['icon'] as IconData,
                name: category['name'] as String,
                code: category['code'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required IconData icon,
    required String name,
    required String code,
  }) {
    return GestureDetector(
      onTap: () {
        if (onCategoryTap != null) {
          onCategoryTap!(code, name);
        }
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.spacingXSmall),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
