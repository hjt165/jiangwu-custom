import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../common/button_widget.dart';
import '../common/bottom_bar_widget.dart';

/// 订单详情页底部操作栏
/// 根据订单状态显示不同的操作按钮

class OrderDetailBottomBar extends StatelessWidget {
  final Order order;
  final VoidCallback? onCancel;
  final VoidCallback? onPay;
  final VoidCallback? onConfirmStage;
  final VoidCallback? onReview;

  const OrderDetailBottomBar({
    super.key,
    required this.order,
    this.onCancel,
    this.onPay,
    this.onConfirmStage,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return BottomBarContainer(
      child: Row(
        children: [
          if (order.canCancel) ...[
            Expanded(
              child: ButtonWidget(
                text: '取消订单',
                isOutlined: true,
                onPressed: onCancel,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
          ],
          if (order.canPay) ...[
            Expanded(
              child: ButtonWidget(
                text: '立即支付',
                onPressed: onPay,
              ),
            ),
          ],
          if (order.status == OrderStatus.stageDelivering) ...[
            Expanded(
              child: ButtonWidget(
                text: '确认本阶段',
                onPressed: onConfirmStage,
              ),
            ),
          ],
          if (order.status == OrderStatus.completed && order.review == null) ...[
            Expanded(
              child: ButtonWidget(
                text: '去评价',
                onPressed: onReview,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
