import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../widgets/common/async_data_view.dart';

/// 订单列表页
/// 订单状态筛选、订单卡片展示

class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['全部', '待确认', '进行中', '待收货', '已完成'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    Future.microtask(() {
      ref.read(orderProvider.notifier).fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      body: Column(
        children: [
          // 页面标题
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '我的订单',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // 状态筛选Tab
          TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
          ),
          // 订单列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildOrderList(tab, orderState)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String tab, OrderProvider orderState) {
    List<Order> filteredOrders = orderState.orders;
    if (tab != '全部') {
      final statusMap = {
        '待确认': OrderStatus.paid,
        '进行中': OrderStatus.producing,
        '待收货': OrderStatus.stageDelivering,
        '已完成': OrderStatus.completed,
      };
      final status = statusMap[tab];
      if (status != null) {
        filteredOrders = orderState.orders.where((o) => o.status == status).toList();
      }
    }

    return AsyncDataView(
      isLoading: orderState.isLoading && orderState.orders.isEmpty,
      error: orderState.orders.isEmpty ? orderState.error : null,
      isEmpty: filteredOrders.isEmpty,
      onRetry: () => orderState.fetchOrders(),
      emptyIcon: Icons.receipt_long_outlined,
      emptyMessage: '暂无订单',
      builder: (context) => RefreshIndicator(
        onRefresh: () => orderState.fetchOrders(refresh: true),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(filteredOrders[index]);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.orderDetail,
          arguments: order.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: AppSizes.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单头部
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '订单编号：${order.orderNo}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 订单内容
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  // 作品图片
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: order.product?.coverImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            child: Image.network(
                              order.product!.coverImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_outlined,
                                size: 24,
                                color: AppColors.textHint,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            size: 24,
                            color: AppColors.textHint,
                          ),
                  ),
                  const SizedBox(width: AppSizes.spacingMedium),
                  // 作品信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.product?.title ?? '定制作品',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.spacingXSmall),
                        Text(
                          order.artisan?.name ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.spacingSmall),
                        Text(
                          '¥${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 订单操作
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.orderDetail,
                        arguments: order.id,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingMedium,
                        vertical: AppSizes.spacingSmall,
                      ),
                    ),
                    child: const Text('查看详情'),
                  ),
                  if (order.status == OrderStatus.stageDelivering) ...[
                    const SizedBox(width: AppSizes.spacingSmall),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.stageConfirm,
                          arguments: order.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingMedium,
                          vertical: AppSizes.spacingSmall,
                        ),
                      ),
                      child: const Text('确认收货'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return AppColors.warning;
      case OrderStatus.paid:
        return AppColors.info;
      case OrderStatus.producing:
        return AppColors.primary;
      case OrderStatus.stageDelivering:
        return AppColors.accent;
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.textHint;
      case OrderStatus.refunding:
        return AppColors.warning;
      case OrderStatus.delayed:
        return AppColors.error;
      case OrderStatus.disputed:
        return AppColors.error;
    }
  }
}