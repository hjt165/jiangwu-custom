import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/constants.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';
import 'auth/login_screen.dart';

/// 启动页
/// 检查登录状态，自动跳转

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 延迟展示启动页
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // 尝试恢复会话
    final isLoggedIn = await ref.read(userProvider.notifier).restoreSession();

    if (!mounted) return;

    if (isLoggedIn) {
      // 已登录，跳转首页
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      // 未登录，跳转登录页
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: AppColors.white,
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              AppStrings.appSlogan,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: AppSizes.spacingXLarge),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}