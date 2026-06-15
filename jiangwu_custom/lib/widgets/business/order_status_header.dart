import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/order.dart';

/// 订单状态头部组件
/// 显示订单状态、订单号、倒计时等信息

class OrderStatusHeader extends StatelessWidget {
  final Order order;

  const OrderStatusHeader({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getStatusColors(),
        ),
      ),
      child: Column(
        children: [
          // 状态图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(),
              size: 40,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSizes.spacingMedium),

          // 状态文字
          Text(
            order.status.label,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),

          // 状态描述
          Text(
            _getStatusDescription(),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacingMedium),

          // 订单号
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              '订单号: ${order.orderNo}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.white,
              ),
            ),
          ),

          // 倒计时（仅待支付状态显示）
          if (order.status == OrderStatus.pendingPayment) ...[
            const SizedBox(height: AppSizes.spacingMedium),
            _buildCountdownTimer(),
          ],
        ],
      ),
    );
  }

  List<Color> _getStatusColors() {
    switch (order.status) {
      case OrderStatus.pendingPayment:
        return [const Color(0xFFF39C12), const Color(0xFFE74C3C)];
      case OrderStatus.paid:
        return [const Color(0xFF3498DB), const Color(0xFF2980B9)];
      case OrderStatus.producing:
        return [const Color(0xFF9B59B6), const Color(0xFF8E44AD)];
      case OrderStatus.stageDelivering:
        return [const Color(0xFF1ABC9C), const Color(0xFF16A085)];
      case OrderStatus.completed:
        return [const Color(0xFF27AE60), const Color(0xFF229954)];
      case OrderStatus.cancelled:
        return [const Color(0xFF95A5A6), const Color(0xFF7F8C8D)];
      case OrderStatus.refunding:
        return [const Color(0xFFE74C3C), const Color(0xFFC0392B)];
      case OrderStatus.delayed:
        return [const Color(0xFFE67E22), const Color(0xFFD35400)];
      case OrderStatus.disputed:
        return [const Color(0xFFE74C3C), const Color(0xFFC0392B)];
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.pendingPayment:
        return Icons.payment;
      case OrderStatus.paid:
        return Icons.check_circle;
      case OrderStatus.producing:
        return Icons.precision_manufacturing;
      case OrderStatus.stageDelivering:
        return Icons.local_shipping;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunding:
        return Icons.replay;
      case OrderStatus.delayed:
        return Icons.access_time;
      case OrderStatus.disputed:
        return Icons.warning;
    }
  }

  String _getStatusDescription() {
    switch (order.status) {
      case OrderStatus.pendingPayment:
        return '请在30分钟内完成支付，超时订单将自动取消';
      case OrderStatus.paid:
        return '支付成功，手作人即将开始制作';
      case OrderStatus.producing:
        return '手作人正在精心制作中，请耐心等待';
      case OrderStatus.stageDelivering:
        return '手作人已交付阶段成果，请确认';
      case OrderStatus.completed:
        return '订单已完成，感谢您的信任';
      case OrderStatus.cancelled:
        return '订单已取消';
      case OrderStatus.refunding:
        return '退款申请处理中，请耐心等待';
      case OrderStatus.delayed:
        return '订单制作延期，请与手作人沟通';
      case OrderStatus.disputed:
        return '订单存在争议，客服正在处理中';
    }
  }

  Widget _buildCountdownTimer() {
    // 模拟倒计时，实际应从订单创建时间计算
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time,
            size: 16,
            color: AppColors.white,
          ),
          const SizedBox(width: AppSizes.spacingXSmall),
          Text(
            '剩余 29:59',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
