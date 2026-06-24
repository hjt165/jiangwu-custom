import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../common/app_card.dart';

/// 提现记录卡片组件
/// 展示单条提现记录信息

class WithdrawRecordCard extends StatelessWidget {
  final String id;
  final double amount;
  final String status; // pending, success, failed
  final String accountType; // alipay, wechat, bank
  final String accountInfo;
  final DateTime createdAt;

  const WithdrawRecordCard({
    super.key,
    required this.id,
    required this.amount,
    required this.status,
    required this.accountType,
    required this.accountInfo,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Row(
        children: [
          // 提现图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getIconColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
            ),
            child: Icon(
              _getIcon(),
              size: 20,
              color: _getIconColor(),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),

          // 提现信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingSmall,
                        vertical: AppSizes.spacingXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Text(
                        _getStatusLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingXSmall),
                Text(
                  '${_getAccountTypeLabel()}: $accountInfo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXSmall),
                Text(
                  '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (accountType) {
      case 'alipay':
        return Icons.account_balance_wallet;
      case 'wechat':
        return Icons.chat_bubble;
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  Color _getIconColor() {
    switch (accountType) {
      case 'alipay':
        return AppColors.blue;
      case 'wechat':
        return AppColors.green;
      case 'bank':
        return AppColors.brown;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getAccountTypeLabel() {
    switch (accountType) {
      case 'alipay':
        return '支付宝';
      case 'wechat':
        return '微信';
      case 'bank':
        return '银行卡';
      default:
        return '账户';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'success':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case 'success':
        return '已到账';
      case 'pending':
        return '处理中';
      case 'failed':
        return '已失败';
      default:
        return '未知';
    }
  }
}
