import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/order.dart';

/// 订单支付信息卡片
/// 展示订单总价、已付金额、尾款、保证金等支付信息

class OrderPaymentInfoCard extends StatelessWidget {
  final Order order;

  const OrderPaymentInfoCard({super.key, required this.order});

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
                Icons.account_balance_wallet,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '支付信息',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          _buildPaymentRow('订单总价', '¥${order.totalAmount.toStringAsFixed(2)}'),
          _buildPaymentRow('已付金额', '¥${order.paidAmount.toStringAsFixed(2)}'),
          _buildPaymentRow(
            '尾款',
            '¥${(order.totalAmount - order.paidAmount).toStringAsFixed(2)}',
            textColor: AppColors.accent,
          ),
          if (order.depositAmount > 0)
            _buildPaymentRow('保证金', '¥${order.depositAmount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {Color? textColor}) {
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
