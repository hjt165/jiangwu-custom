import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../providers/artisan_order_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_widget.dart';

/// 手作人订单管理页面
/// 展示手作人收到的订单列表，支持状态筛选

class OrderManageScreen extends ConsumerStatefulWidget {
  const OrderManageScreen({super.key});

  @override
  ConsumerState<OrderManageScreen> createState() => _OrderManageScreenState();
}

class _OrderManageScreenState extends ConsumerState<OrderManageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    const Tab(text: '全部'),
    const Tab(text: '待接单'),
    const Tab(text: '制作中'),
    const Tab(text: '待交付'),
    const Tab(text: '已完成'),
  ];

  final _statusFilters = [
    null, // 全部
    OrderStatus.paid, // 待接单 (已支付待制作)
    OrderStatus.producing, // 制作中
    OrderStatus.stageDelivering, // 待交付
    OrderStatus.completed, // 已完成
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // 加载全部订单
    Future.microtask(() {
      ref.read(artisanOrderProvider.notifier).fetchOrders(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final status = _statusFilters[_tabController.index];
      ref.read(artisanOrderProvider.notifier).fetchOrders(
        status: status,
        refresh: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(artisanOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('订单管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: _buildBody(orderState),
    );
  }

  Widget _buildBody(ArtisanOrderProvider orderState) {
    if (orderState.isLoading && orderState.orders.isEmpty) {
      return const LoadingWidget();
    }

    if (orderState.error != null && orderState.orders.isEmpty) {
      return CustomErrorWidget(
        message: orderState.error!,
        onRetry: () {
          ref.read(artisanOrderProvider.notifier).fetchOrders(refresh: true);
        },
      );
    }

    if (orderState.orders.isEmpty) {
      return const EmptyWidget(message: '暂无订单');
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(artisanOrderProvider.notifier).fetchOrders(refresh: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        itemCount: orderState.orders.length,
        itemBuilder: (context, index) {
          final order = orderState.orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/order/${order.id}',
          arguments: order.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: AppSizes.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单号和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '订单号: ${order.orderNo}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // 商品信息
            Row(
              children: [
                // 商品图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.border,
                    child: order.product?.firstImage != null
                        ? Image.network(
                            order.product!.firstImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image,
                              color: AppColors.textHint,
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            color: AppColors.textHint,
                          ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMedium),

                // 商品详情
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.product?.title ?? '未知商品',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.spacingXSmall),
                      Text(
                        '买家: ${order.userId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingXSmall),
                      Text(
                        '¥${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            // 操作按钮
            if (order.status == OrderStatus.paid)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleRejectOrder(order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('拒绝'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAcceptOrder(order.id),
                      child: const Text('接受'),
                    ),
                  ),
                ],
              ),
            if (order.status == OrderStatus.producing ||
                order.status == OrderStatus.stageDelivering)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleDeliverStage(order),
                  child: const Text('提交阶段交付'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final statusMap = {
      OrderStatus.paid: {'label': '待接单', 'color': AppColors.warning},
      OrderStatus.producing: {'label': '制作中', 'color': AppColors.blue},
      OrderStatus.stageDelivering: {'label': '待交付', 'color': AppColors.info},
      OrderStatus.completed: {'label': '已完成', 'color': AppColors.success},
      OrderStatus.cancelled: {'label': '已取消', 'color': AppColors.textHint},
      OrderStatus.disputed: {'label': '争议中', 'color': AppColors.error},
    };

    final info = statusMap[status] ?? {'label': '未知', 'color': AppColors.textHint};

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingSmall,
        vertical: AppSizes.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: (info['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        info['label'] as String,
        style: TextStyle(
          fontSize: 11,
          color: info['color'] as Color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleAcceptOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('接受订单'),
        content: const Text('确定接受此订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(artisanOrderProvider.notifier)
                  .acceptOrder(orderId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '已接受订单' : '操作失败'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _handleRejectOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝订单'),
        content: const Text('确定拒绝此订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(artisanOrderProvider.notifier)
                  .rejectOrder(orderId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '已拒绝订单' : '操作失败'),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('确定拒绝'),
          ),
        ],
      ),
    );
  }

  void _handleDeliverStage(Order order) {
    Navigator.pushNamed(context, AppRoutes.stageConfirm, arguments: order.id);
  }
}
