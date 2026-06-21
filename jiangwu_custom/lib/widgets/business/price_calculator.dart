import 'package:flutter/material.dart';

class PriceCalculator extends StatelessWidget {
  final double basePrice;
  final double? materialFee;
  final double? craftFee;
  final double? complexityFee;
  final int quantity;
  final bool showBreakdown;

  const PriceCalculator({
    super.key,
    required this.basePrice,
    this.materialFee,
    this.craftFee,
    this.complexityFee,
    this.quantity = 1,
    this.showBreakdown = true,
  });

  double get materialTotal => (materialFee ?? 0);
  double get craftTotal => (craftFee ?? 0);
  double get complexityTotal => (complexityFee ?? 0);
  double get unitPrice => basePrice + materialTotal + craftTotal + complexityTotal;
  double get totalPrice => unitPrice * quantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '费用明细',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildRow('基础价格', basePrice),
            if (materialFee != null && materialFee! > 0)
              _buildRow('材料费', materialTotal),
            if (craftFee != null && craftFee! > 0)
              _buildRow('工艺费', craftTotal),
            if (complexityFee != null && complexityFee! > 0)
              _buildRow('复杂度加价', complexityTotal),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '单价',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '¥${unitPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (quantity > 1) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('数量 × $quantity', style: theme.textTheme.bodySmall),
                  Text(
                    '¥${totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (quantity == 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '¥${totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text('¥${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
