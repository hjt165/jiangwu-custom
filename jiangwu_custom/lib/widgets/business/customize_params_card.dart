import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/customization.dart';

/// 定制参数展示组件
/// 只读展示用户选择的定制参数

class CustomizeParamsCard extends StatelessWidget {
  final Customization customization;

  const CustomizeParamsCard({
    super.key,
    required this.customization,
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
          const Row(
            children: [
              Icon(
                Icons.tune,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '定制参数',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // 参数列表
          _buildParamRow('材质', customization.material),
          _buildParamRow('尺寸', customization.size),
          _buildParamRow('颜色', customization.color),
          _buildParamRow('雕刻内容', customization.engraving),

          // 补充描述
          if (customization.description != null &&
              customization.description!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            const Text(
              '补充描述',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Text(
                customization.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    final isEmpty = value.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isEmpty ? '未设置' : value,
              style: TextStyle(
                fontSize: 14,
                color: isEmpty ? AppColors.textHint : AppColors.textPrimary,
                fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
