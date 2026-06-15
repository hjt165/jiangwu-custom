import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/business/order_status_header.dart';
import '../../widgets/business/order_info_card.dart';
import '../../widgets/business/stage_timeline.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/button_widget.dart';
import '../chat/chat_screen.dart';

/// 订单详情页
/// 展示订单完整信息、状态流转、操作入口

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 加载订单详情
    Future.microtask(() {
      ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('订单详情'),
        actions: [
          IconButton(
            onPressed: () => _showMoreActions(),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: _buildBody(orderState),
      bottomNavigationBar: orderState.currentOrder != null
          ? _buildBottomBar(orderState.currentOrder!)
          : null,
    );
  }

  Widget _buildBody(OrderProvider orderState) {
    if (orderState.isLoading && orderState.currentOrder == null) {
      return const LoadingWidget();
    }

    if (orderState.error != null && orderState.currentOrder == null) {
      return CustomErrorWidget(
        message: orderState.error!,
        onRetry: () {
          ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId);
        },
      );
    }

    if (orderState.currentOrder == null) {
      return const EmptyWidget(message: '订单不存在');
    }

    final order = orderState.currentOrder!;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 状态头部
            OrderStatusHeader(order: order),
            const SizedBox(height: AppSizes.spacingMedium),

            // 订单信息卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              child: OrderInfoCard(
                order: order,
                onContactArtisan: () => _handleContactArtisan(order),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // 阶段时间线
            if (order.stages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                child: StageTimeline(
                  stages: order.stages,
                  currentStage: order.currentStage,
                ),
              ),
            const SizedBox(height: AppSizes.spacingMedium),

            // 支付信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              child: _buildPaymentInfo(order),
            ),
            const SizedBox(height: AppSizes.spacingMedium),

            // 订单信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              child: _buildOrderInfo(order),
            ),
            const SizedBox(height: 100), // 底部留白
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(Order order) {
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

  Widget _buildOrderInfo(Order order) {
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
          _buildInfoRow('创建时间', _formatDateTime(order.createdAt)),
          _buildInfoRow('更新时间', _formatDateTime(order.updatedAt)),
          if (order.paidAt != null)
            _buildInfoRow('支付时间', _formatDateTime(order.paidAt!)),
          if (order.completedAt != null)
            _buildInfoRow('完成时间', _formatDateTime(order.completedAt!)),
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

  Widget _buildBottomBar(Order order) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingMedium,
        right: AppSizes.paddingMedium,
        top: AppSizes.paddingMedium,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 根据状态显示不同按钮
          if (order.canCancel) ...[
            Expanded(
              child: ButtonWidget(
                text: '取消订单',
                isOutlined: true,
                onPressed: () => _handleCancelOrder(order),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
          ],
          if (order.canPay) ...[
            Expanded(
              child: ButtonWidget(
                text: '立即支付',
                onPressed: () => _handlePayOrder(order),
              ),
            ),
          ],
          if (order.status == OrderStatus.stageDelivering) ...[
            Expanded(
              child: ButtonWidget(
                text: '确认本阶段',
                onPressed: () => _handleConfirmStage(order),
              ),
            ),
          ],
          if (order.status == OrderStatus.completed && order.review == null) ...[
            Expanded(
              child: ButtonWidget(
                text: '评价',
                onPressed: () => _handleReviewOrder(order),
              ),
            ),
          ],
          if (order.status == OrderStatus.producing) ...[
            Expanded(
              child: ButtonWidget(
                text: '联系手作人',
                onPressed: () => _handleContactArtisan(order),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleCancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('取消订单'),
        content: const Text('确定要取消此订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('再想想'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref.read(orderProvider.notifier).cancelOrder(order.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '订单已取消' : '取消失败'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('确定取消'),
          ),
        ],
      ),
    );
  }

  void _handlePayOrder(Order order) {
    Navigator.pushNamed(context, AppRoutes.pay, arguments: order.id);
  }

  void _handleConfirmStage(Order order) {
    Navigator.pushNamed(context, AppRoutes.stageConfirm, arguments: order.id);
  }

  void _handleReviewOrder(Order order) {
    Navigator.pushNamed(context, AppRoutes.review, arguments: order.id);
  }

  void _handleContactArtisan(Order order) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null || order.artisanId == null) return;

    try {
      final chatService = ref.read(chatServiceProvider);
      final conversation = await chatService.getOrCreateConversation(
        user.id,
        order.artisanId!,
        orderId: int.tryParse(order.id),
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation.id,
              otherName: order.artisan?.name ?? '手作人',
              otherAvatar: order.artisan?.avatar,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建会话失败: $e')),
        );
      }
    }
  }

  void _showMoreActions() {
    final order = ref.read(orderProvider).currentOrder;
    if (order == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享订单'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('分享功能开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.customer_service),
              title: const Text('联系客服'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('客服功能开发中')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('举报'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('举报功能开发中')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
