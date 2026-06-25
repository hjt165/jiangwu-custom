import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../utils/date_utils.dart';

/// 订单信息区块
/// 展示订单编号、创建时间、支付时间等基本信息

class OrderInfoSection extends StatelessWidget {
  final Order order;

  const OrderInfoSection({super.key, required this.order});

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
          const Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '订单信息',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildInfoRow('订单编号', order.orderNo),
          _buildInfoRow('创建时间', AppDateUtils.formatYMDHM(order.createdAt)),
          _buildInfoRow('更新时间', AppDateUtils.formatYMDHM(order.updatedAt)),
          if (order.paidAt != null)
            _buildInfoRow('支付时间', AppDateUtils.formatYMDHM(order.paidAt!)),
          if (order.completedAt != null)
            _buildInfoRow('完成时间', AppDateUtils.formatYMDHM(order.completedAt!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
