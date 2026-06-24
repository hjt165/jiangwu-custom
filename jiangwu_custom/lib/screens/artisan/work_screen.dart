import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../providers/artisan_workspace_provider.dart';
import '../../providers/artisan_order_provider.dart';
import '../../widgets/business/workspace_stats_card.dart';
import '../../widgets/business/pending_order_card.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/async_data_view.dart';
import '../../widgets/common/empty_widget.dart';

/// 手作人工作台页面
/// 展示统计数据、待处理订单、快捷入口

class WorkScreen extends ConsumerStatefulWidget {
  const WorkScreen({super.key});

  @override
  ConsumerState<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends ConsumerState<WorkScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(artisanWorkspaceProvider.notifier).fetchWorkspaceData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspaceState = ref.watch(artisanWorkspaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('工作台'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(artisanWorkspaceProvider.notifier).fetchWorkspaceData();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(workspaceState),
    );
  }

  Widget _buildBody(ArtisanWorkspaceProvider workspaceState) {
    return AsyncDataView(
      isLoading: workspaceState.isLoading && workspaceState.pendingOrders.isEmpty && workspaceState.stats.isEmpty,
      error: workspaceState.stats.isEmpty ? workspaceState.error : null,
      isEmpty: false,
      onRetry: () => ref.read(artisanWorkspaceProvider.notifier).fetchWorkspaceData(),
      builder: (context) => RefreshIndicator(
        onRefresh: () async {
          await ref.read(artisanWorkspaceProvider.notifier).fetchWorkspaceData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkspaceStatsCard(
                pendingOrders: workspaceState.stats['pendingOrders'] ?? 0,
                todayOrders: workspaceState.stats['todayOrders'] ?? 0,
                monthIncome: (workspaceState.stats['monthIncome'] ?? 0.0).toDouble(),
                totalWorks: workspaceState.stats['totalWorks'] ?? 0,
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              _buildQuickActions(),
              const SizedBox(height: AppSizes.spacingLarge),
              _buildPendingOrders(workspaceState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快捷入口',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionItem(
                icon: Icons.receipt_long,
                label: '订单管理',
                onTap: () {
                  Navigator.pushNamed(context, '/artisan/orders');
                },
              ),
              _buildQuickActionItem(
                icon: Icons.inventory,
                label: '作品管理',
                onTap: () {
                  Navigator.pushNamed(context, '/artisan/products');
                },
              ),
              _buildQuickActionItem(
                icon: Icons.account_balance_wallet,
                label: '收入统计',
                onTap: () {
                  Navigator.pushNamed(context, '/artisan/income');
                },
              ),
              _buildQuickActionItem(
                icon: Icons.settings,
                label: '设置',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
            ),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingOrders(ArtisanWorkspaceProvider workspaceState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '待处理订单',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (workspaceState.pendingOrders.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/artisan/orders');
                },
                child: const Text(
                  '查看全部',
                  style: TextStyle(fontSize: 13, color: AppColors.primary),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingSmall),
        if (workspaceState.pendingOrders.isEmpty)
          EmptyWidget(message: '暂无待处理订单')
        else
          ...workspaceState.pendingOrders.take(3).map((order) {
            return PendingOrderCard(
              order: order,
              onAccept: () => _handleAcceptOrder(order.id),
              onReject: () => _handleRejectOrder(order.id),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.orderDetail,
                  arguments: order.id,
                );
              },
            );
          }),
      ],
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
                if (success) {
                  ref.read(artisanWorkspaceProvider.notifier).fetchWorkspaceData();
                }
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
                if (success) {
                  ref.read(artisanWorkspaceProvider.notifier).fetchWorkspaceData();
                }
              }
            },
            child: const Text('确定拒绝'),
          ),
        ],
      ),
    );
  }
}