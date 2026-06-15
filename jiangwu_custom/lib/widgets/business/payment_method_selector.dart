import 'package:flutter/material.dart';
import '../../app/constants.dart';

/// 支付方式枚举
enum PaymentMethod {
  alipay('支付宝', Icons.account_balance_wallet, Color(0xFF1677FF)),
  wechat('微信支付', Icons.chat_bubble_outline, Color(0xFF07C160)),
  bankCard('银行卡', Icons.credit_card, AppColors.primary);

  final String label;
  final IconData icon;
  final Color color;

  const PaymentMethod(this.label, this.icon, this.color);
}

/// 支付方式选择组件
/// 单选支付方式（支付宝、微信、银行卡）

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
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
          const Row(
            children: [
              Icon(
                Icons.payment,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '选择支付方式',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          ...PaymentMethod.values.map((method) {
            return _buildPaymentOption(method);
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method) {
    final isSelected = selected == method;

    return GestureDetector(
      onTap: () => onSelected(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? method.color.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isSelected ? method.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              method.icon,
              size: 28,
              color: isSelected ? method.color : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Text(
                method.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? method.color : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 22,
              color: isSelected ? method.color : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
