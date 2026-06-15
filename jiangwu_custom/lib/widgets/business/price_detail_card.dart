import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 报价明细组件
/// 展示材料费、工费、工期、合计金额

class PriceDetailCard extends StatelessWidget {
  final double materialCost;
  final double laborCost;
  final int estimatedDays;
  final String difficulty;
  final VoidCallback? onConfirm;

  const PriceDetailCard({
    super.key,
    required this.materialCost,
    required this.laborCost,
    this.estimatedDays = 7,
    this.difficulty = '中等',
    this.onConfirm,
  });

  double get totalAmount => materialCost + laborCost;

  String get _difficultyText {
    switch (difficulty) {
      case '简单':
        return '简单';
      case '中等':
        return '中等';
      case '复杂':
        return '复杂';
      case '高难度':
        return '高难度';
      default:
        return difficulty;
    }
  }

  Color get _difficultyColor {
    switch (difficulty) {
      case '简单':
        return AppColors.success;
      case '中等':
        return AppColors.primary;
      case '复杂':
        return AppColors.accent;
      case '高难度':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

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
                Icons.receipt_long,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '报价明细',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),

          // 费用明细
          _buildCostRow('材料费', '¥${materialCost.toStringAsFixed(2)}'),
          _buildCostRow('工费', '¥${laborCost.toStringAsFixed(2)}'),
          const Divider(height: AppSizes.paddingMedium),

          // 工艺信息
          _buildInfoRow(
            '工艺难度',
            _difficultyText,
            valueColor: _difficultyColor,
          ),
          _buildInfoRow('预计工期', '$estimatedDays 天'),
          const SizedBox(height: AppSizes.paddingMedium),

          // 合计金额
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '合计金额',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '¥${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
