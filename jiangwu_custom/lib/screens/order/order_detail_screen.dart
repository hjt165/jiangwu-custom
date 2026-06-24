import 'package:flutter/material.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/chat_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/blockchain_service.dart';
import '../../widgets/business/order_status_header.dart';
import '../../widgets/business/order_info_card.dart';
import '../../widgets/business/stage_timeline.dart';
import '../../widgets/common/async_data_view.dart';
import '../../widgets/common/button_widget.dart';
import '../../widgets/common/bottom_bar_widget.dart';
import '../../utils/share_utils.dart';
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
                const SizedBox(height: AppSizes.spacingMedium),

                // 溯源信息
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                  child: _buildTraceInfo(order),
                ),
                const SizedBox(height: 100), // 底部留白
              ],
            ),
          ),
        );
      },
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

  Widget _buildTraceInfo(Order order) {
    return FutureBuilder<List<BlockchainRecord>>(
      future: BlockchainService().getRecords(order.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final records = snapshot.data ?? [];

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
                    Icons.verified,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSizes.spacingSmall),
                  Text(
                    '溯源存证',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              if (records.isEmpty)
                const Text(
                  '暂无存证记录',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                )
              else
                ...records.map((record) => _buildTraceRecordItem(record)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTraceRecordItem(BlockchainRecord record) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSmall),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: record.isVerified ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getBlockchainTypeName(record.type),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (record.timestamp != null)
                  Text(
                    record.timestamp!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            record.isVerified ? Icons.check_circle : Icons.pending,
            size: 16,
            color: record.isVerified ? AppColors.success : AppColors.warning,
          ),
        ],
      ),
    );
  }

  String _getBlockchainTypeName(String type) {
    switch (type) {
      case 'order_created': return '订单创建';
      case 'order_signed': return '订单签订';
      case 'stage_delivered': return '阶段交付';
      case 'final_delivered': return '最终交付';
      case 'review_completed': return '评价完成';
      default: return type;
    }
  }

  Widget _buildBottomBar(Order order) {
    return BottomBarContainer(
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
                text: '去评价',
                onPressed: () => _handleReviewOrder(order),
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
