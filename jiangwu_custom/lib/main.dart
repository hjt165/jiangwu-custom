import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';

/// 全局NavigatorKey，用于401时跳转登录页
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化存储服务
  await StorageService().init();

  // 设置401未授权回调
  ApiService.onUnauthorized = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  };

  runApp(
    ProviderScope(
      child: JiangwuApp(navigatorKey: navigatorKey),
    ),
  );
}