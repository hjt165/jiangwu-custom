import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../app/constants.dart';
import '../../widgets/common/app_card.dart';
import '../../providers/user_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';

/// 个人中心主页面
/// 个人信息、收藏夹、浏览历史、设置

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _pendingPaymentCount = 0;
  int _producingCount = 0;
  int _stageDeliveringCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderStats();
    });
  }

  Future<void> _loadOrderStats() async {
    try {
      await ref.read(orderProvider.notifier).fetchOrders();
      if (!mounted) return;
      final orders = ref.read(orderProvider).orders;
      setState(() {
        _pendingPaymentCount = orders.where((o) => o.status == OrderStatus.pendingPayment).length;
        _producingCount = orders.where((o) => o.status == OrderStatus.producing).length;
        _stageDeliveringCount = orders.where((o) => o.status == OrderStatus.stageDelivering).length;
        _completedCount = orders.where((o) => o.status == OrderStatus.completed).length;
      });
    } catch (e, stack) {
      developer.log('加载订单统计失败', name: 'ProfileScreen', error: e, stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserInfoCard(context, ref, userState),
            _buildOrderStats(context),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, WidgetRef ref, UserNotifier userState) {
    final isLoggedIn = userState.isLoggedIn;
    final user = userState.user;

    return GestureDetector(
      onTap: () {
        if (isLoggedIn) {
          Navigator.pushNamed(context, AppRoutes.editProfile);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: Row(
          children: [
            // 头像
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: user?.avatar != null && user!.avatar!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        user.avatar!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.white,
                    ),
            ),
            const SizedBox(width: AppSizes.spacingMedium),
            Expanded(
              child: isLoggedIn
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nickname ?? '用户',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingXSmall),
                        Text(
                          user?.phone ?? '',
                          style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text(
                        '点击登录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
            ),
            if (isLoggedIn)
              Icon(
                Icons.chevron_right,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStats(BuildContext context) {
    return RepaintBoundary(
      child: AppCard(
        margin: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '我的订单',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.orderList);
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.payment, '待付款', _pendingPaymentCount, context),
                _buildStatItem(Icons.local_shipping, '待发货', _producingCount, context),
                _buildStatItem(Icons.inventory, '待收货', _stageDeliveringCount, context),
                _buildStatItem(Icons.rate_review, '待评价', _completedCount, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, int count, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.orderList);
      },
      child: Column(
        children: [
          Stack(
            children: [
              Icon(icon, size: 28, color: AppColors.textPrimary),
              if (count > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(fontSize: 10, color: AppColors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXSmall),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      {'icon': Icons.favorite, 'title': '我的收藏', 'route': AppRoutes.favorites},
      {'icon': Icons.history, 'title': '浏览历史', 'route': AppRoutes.history},
      {'icon': Icons.settings, 'title': '设置', 'route': AppRoutes.settings},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        children: menuItems.map((item) {
          return Column(
            children: [
              ListTile(
                leading: Icon(item['icon'] as IconData, color: AppColors.primary),
                title: Text(
                  item['title'] as String,
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                onTap: () {
                  Navigator.pushNamed(context, item['route'] as String);
                },
              ),
              if (item != menuItems.last)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}