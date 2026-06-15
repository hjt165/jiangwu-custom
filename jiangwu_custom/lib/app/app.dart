import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';
import '../screens/splash_screen.dart';

/// 应用根Widget配置
/// 配置主题、路由等全局设置

class JiangwuApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const JiangwuApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '匠物定制',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}