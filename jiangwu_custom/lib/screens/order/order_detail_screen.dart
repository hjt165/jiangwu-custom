import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/business/order_status_header.dart';
import '../../widgets/business/order_info_card.dart';
import '../../widgets/business/stage_timeline.dart';
import '../../widgets/business/order_payment_info_card.dart';
import '../../widgets/business/order_info_section.dart';
import '../../widgets/business/order_trace_section.dart';
import '../../widgets/business/order_detail_bottom_bar.dart';
import '../../widgets/common/async_data_view.dart';
import '../../utils/share_utils.dart';
import '../../utils/chat_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          ? OrderDetailBottomBar(
              order: orderState.currentOrder!,
              onCancel: () => _handleCancelOrder(orderState.currentOrder!),
              onPay: () => _handlePayOrder(orderState.currentOrder!),
              onConfirmStage: () => _handleConfirmStage(orderState.currentOrder!),
              onReview: () => _handleReviewOrder(orderState.currentOrder!),
            )
          : null,
    );
  }

  Widget _buildBody(OrderProvider orderState) {
    return AsyncDataView(
      isLoading: orderState.isLoading && orderState.currentOrder == null,
      error: orderState.currentOrder == null ? orderState.error : null,
      isEmpty: orderState.currentOrder == null,
      onRetry: () => ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId),
      emptyMessage: '订单不存在',
      builder: (context) {
        final order = orderState.currentOrder!;
        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(orderProvider.notifier).fetchOrderDetail(widget.orderId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                OrderStatusHeader(order: order),
                const SizedBox(height: AppSizes.spacingMedium),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: OrderInfoCard(
                    order: order,
                    onContactArtisan: () => _handleContactArtisan(order),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMedium),

                if (order.stages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    child: StageTimeline(
                      stages: order.stages,
                      currentStage: order.currentStage,
                    ),
                  ),
                const SizedBox(height: AppSizes.spacingMedium),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: OrderPaymentInfoCard(order: order),
                ),
                const SizedBox(height: AppSizes.spacingMedium),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: OrderInfoSection(order: order),
                ),
                const SizedBox(height: AppSizes.spacingMedium),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: OrderTraceSection(orderId: order.id),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
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

  void _handleContactArtisan(Order order) {
    ChatUtils.contactArtisan(context, ref, order);
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
                final orderState = ref.read(orderProvider);
                final order = orderState.orders.where((o) => o.id == widget.orderId).firstOrNull;
                if (order != null) {
                  ShareUtils.shareOrder(
                    context,
                    orderNo: order.orderNo,
                    productName: order.product?.title,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic),
              title: const Text('联系客服'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('客服热线: 400-888-8888\n工作时间: 9:00-18:00')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('举报'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    final reasons = ['虚假商品', '质量问题', '未按时发货', '其他原因'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('举报订单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((r) => ListTile(
            title: Text(r),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已提交举报: $r')),
              );
            },
          )).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ],
      ),
    );
  }
}
