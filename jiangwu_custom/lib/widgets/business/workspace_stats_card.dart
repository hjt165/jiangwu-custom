import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 工作台统计卡片组件
/// 展示待处理订单、今日订单、本月收入、作品总数

class WorkspaceStatsCard extends StatelessWidget {
  final int pendingOrders;
  final int todayOrders;
  final double monthIncome;
  final int totalWorks;

  const WorkspaceStatsCard({
    super.key,
    required this.pendingOrders,
    required this.todayOrders,
    required this.monthIncome,
    required this.totalWorks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '工作台概览',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.pending_actions,
                label: '待处理',
                value: '$pendingOrders',
                color: AppColors.warning,
              ),
              _buildStatItem(
                icon: Icons.today,
                label: '今日订单',
                value: '$todayOrders',
                color: AppColors.blue,
              ),
              _buildStatItem(
                icon: Icons.account_balance_wallet,
                label: '本月收入',
                value: '¥${monthIncome.toStringAsFixed(0)}',
                color: AppColors.green,
              ),
              _buildStatItem(
                icon: Icons.inventory,
                label: '作品数',
                value: '$totalWorks',
                color: AppColors.brown,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: AppSizes.spacingXSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXSmall),
          Text(
            label,
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
