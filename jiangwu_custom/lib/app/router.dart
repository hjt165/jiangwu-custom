import 'package:flutter/material.dart';
import '../app/constants.dart';
import '../screens/main_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/customize/publish_screen.dart';
import '../screens/customize/confirm_screen.dart';
import '../screens/order/order_list_screen.dart';
import '../screens/order/order_detail_screen.dart';
import '../screens/order/stage_confirm_screen.dart';
import '../screens/order/review_screen.dart';
import '../screens/order/pay_screen.dart';
import '../screens/artisan/artisan_profile_screen.dart';
import '../screens/discover/search_screen.dart';
import '../screens/discover/category_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/favorites_screen.dart';
import '../screens/profile/history_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/customize/preview_screen.dart';
import '../models/product.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/artisan/work_screen.dart';
import '../screens/artisan/order_manage_screen.dart';
import '../screens/artisan/product_manage_screen.dart';
import '../screens/artisan/income_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';

/// 路由配置
/// 定义所有页面路由映射

class AppRouter {
  AppRouter._();

  /// 生成路由
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final args = settings.arguments;

    switch (name) {
      // 认证模块
      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);
      case AppRoutes.register:
        return _buildRoute(const RegisterScreen(), settings);
      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      // 首页
      case AppRoutes.home:
        return _buildRoute(const MainScreen(), settings);

      // 发现模块
      case AppRoutes.discover:
        return _buildRoute(const DiscoverScreen(), settings);
      case AppRoutes.category:
        final categoryName = args as String? ?? '其他';
        final category = ProductCategory.fromString(categoryName);
        return _buildRoute(
          CategoryScreen(category: category),
          settings,
        );
      case AppRoutes.search:
        final keyword = args as String?;
        return _buildRoute(
          SearchScreen(initialKeyword: keyword),
          settings,
        );
      case AppRoutes.artisanProfile:
        final artisanId = args as String? ?? '';
        return _buildRoute(
          ArtisanProfileScreen(artisanId: artisanId),
          settings,
        );

      // 定制模块
      case AppRoutes.publish:
        return _buildRoute(const PublishScreen(), settings);
      case AppRoutes.preview:
        final params = args as Map<String, dynamic>?;
        return _buildRoute(
          PreviewScreen(params: params),
          settings,
        );
      case AppRoutes.confirm:
        return _buildRoute(const ConfirmScreen(), settings);
      case AppRoutes.pay:
        final orderId = args as String? ?? '';
        return _buildRoute(
          PayScreen(orderId: orderId),
          settings,
        );

      // 订单模块
      case AppRoutes.orderList:
        return _buildRoute(const OrderListScreen(), settings);
      case AppRoutes.orderDetail:
        final orderId = args as String? ?? '';
        return _buildRoute(
          OrderDetailScreen(orderId: orderId),
          settings,
        );
      case AppRoutes.stageConfirm:
        final orderId = args as String? ?? '';
        return _buildRoute(
          StageConfirmScreen(orderId: orderId),
          settings,
        );
      case AppRoutes.review:
        final orderId = args as String? ?? '';
        return _buildRoute(
          ReviewScreen(orderId: orderId),
          settings,
        );

      // 个人中心模块
      case AppRoutes.profile:
        return _buildRoute(const ProfileScreen(), settings);
      case AppRoutes.editProfile:
        return _buildRoute(const EditProfileScreen(), settings);
      case AppRoutes.favorites:
        return _buildRoute(const FavoritesScreen(), settings);
      case AppRoutes.history:
        return _buildRoute(const HistoryScreen(), settings);
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);

      // 手作人模块
      case AppRoutes.artisanWork:
        return _buildRoute(const WorkScreen(), settings);
      case AppRoutes.artisanOrders:
        return _buildRoute(const OrderManageScreen(), settings);
      case AppRoutes.artisanProducts:
        return _buildRoute(const ProductManageScreen(), settings);
      case AppRoutes.artisanIncome:
        return _buildRoute(const IncomeScreen(), settings);

      // 聊天模块
      case AppRoutes.chatList:
        return _buildRoute(const ChatListScreen(), settings);
      case AppRoutes.chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ChatScreen(
            conversationId: args?['conversationId'] ?? 0,
            otherName: args?['otherName'] ?? '聊天',
            otherAvatar: args?['otherAvatar'],
          ),
          settings,
        );

      default:
        return _buildRoute(const MainScreen(), settings);
    }
  }

  /// 构建路由
  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
