import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../providers/user_provider.dart';

/// 设置页面

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppSizes.spacingMedium),
          _buildSection(
            children: [
              _buildMenuItem(
                icon: Icons.location_on,
                title: '收货地址',
                onTap: () => Navigator.pushNamed(context, AppRoutes.addressList),
              ),
              _buildMenuItem(
                icon: Icons.lock_outline,
                title: '修改密码',
                onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          _buildSection(
            children: [
              _buildMenuItem(
                icon: Icons.description,
                title: '用户协议',
                onTap: () => Navigator.pushNamed(context, AppRoutes.agreement),
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip,
                title: '隐私政策',
                onTap: () => Navigator.pushNamed(context, AppRoutes.privacy),
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: '帮助中心',
                onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
              ),
              _buildMenuItem(
                icon: Icons.feedback,
                title: '意见反馈',
                onTap: () => Navigator.pushNamed(context, AppRoutes.feedback),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          // 退出登录
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: OutlinedButton(
              onPressed: () {
                _showLogoutDialog(context, ref);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMedium),
              ),
              child: const Text('退出登录'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(title, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(userProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            child: const Text('确定', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}