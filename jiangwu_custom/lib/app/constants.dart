import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 应用常量定义
/// 统一管理颜色、字体、间距等常量，避免变量冲突

class AppColors {
  AppColors._();

  // 主色调
  static const Color primary = Color(0xFF2C3E50);      // 墨色
  static const Color accent = Color(0xFFE74C3C);       // 朱砂红
  static const Color background = Color(0xFFF5F5F0);   // 米白

  // 辅助色
  static const Color blue = Color(0xFF3498DB);         // 青瓷蓝
  static const Color green = Color(0xFF27AE60);        // 竹绿
  static const Color brown = Color(0xFF8B4513);        // 檀木棕

  // 状态色
  static const Color success = Color(0xFF27AE60);      // 成功
  static const Color error = Color(0xFFE74C3C);        // 错误
  static const Color warning = Color(0xFFF39C12);      // 警告
  static const Color info = Color(0xFF3498DB);         // 信息

  // 边框色
  static const Color border = Color(0xFFECF0F1);       // 边框
  static const Color borderLight = Color(0xFFF5F5F5);  // 浅边框

  // 中性色
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color divider = Color(0xFFECF0F1);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

class AppFonts {
  AppFonts._();

  static const String titleFont = 'NotoSerifSC';
  static const String bodyFont = 'NotoSansSC';
}

class AppSizes {
  AppSizes._();

  // 圆角
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusCircle = 50.0;

  // 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // 内边距
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // 阴影
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
  ];
}

class AppStrings {
  AppStrings._();

  static const String appName = '匠物定制';
  static const String appSlogan = '小众手作艺术品定制平台';

  // 通用文本
  static const String loading = '加载中...';
  static const String retry = '重试';
  static const String confirm = '确认';
  static const String cancel = '取消';
  static const String save = '保存';
  static const String delete = '删除';
  static const String edit = '编辑';
  static const String back = '返回';
  static const String noData = '暂无数据';
  static const String networkError = '网络错误，请重试';
}

/// 路由路径常量
class AppRoutes {
  AppRoutes._();

  // 认证模块
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // 首页模块
  static const String home = '/';

  // 发现模块
  static const String discover = '/discover';
  static const String category = '/discover/category';
  static const String search = '/discover/search';
  static const String artisanProfile = '/artisan/:id';

  // 定制模块
  static const String publish = '/customize/publish';
  static const String preview = '/customize/preview';
  static const String confirm = '/customize/confirm';
  static const String pay = '/customize/pay';

  // 订单模块
  static const String orderList = '/order/list';
  static const String orderDetail = '/order/:id';
  static const String stageConfirm = '/order/:id/confirm';
  static const String review = '/order/:id/review';

  // 个人中心模块
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String favorites = '/profile/favorites';
  static const String history = '/profile/history';
  static const String settings = '/profile/settings';
  static const String agreement = '/profile/agreement';
  static const String privacy = '/profile/privacy';
  static const String helpCenter = '/profile/help-center';
  static const String feedback = '/profile/feedback';
  static const String changePassword = '/profile/change-password';
  static const String addressList = '/profile/address-list';
  static const String addressEdit = '/profile/address-edit';

  // 手作人模块
  static const String artisanWork = '/artisan/work';
  static const String artisanOrders = '/artisan/orders';
  static const String artisanProducts = '/artisan/products';
  static const String artisanIncome = '/artisan/income';

  // 聊天模块
  static const String chatList = '/chat/list';
  static const String chat = '/chat/:conversationId';

  // 作品模块
  static const String productDetail = '/product/:id';
}

/// API配置常量
class ApiConstants {
  ApiConstants._();

  // 开发环境
  static const String devBaseUrl = 'http://10.0.2.2:8080/api';
  // 生产环境
  static const String prodBaseUrl = 'https://api.jiangwu.com/api';

  // Web 平台使用 localhost，其他平台使用 10.0.2.2（Android模拟器）
  static String get baseUrl => kIsWeb ? 'http://localhost:8080/api' : devBaseUrl;

  // 超时时间（毫秒）
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;

  // 分页默认值
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 微信开放平台appId
  static const String wechatAppId = 'your-wechat-app-id';
}

/// 缓存Key常量
class CacheKeys {
  CacheKeys._();

  static const String token = 'token';
  static const String userInfo = 'userInfo';
  static const String themeMode = 'themeMode';
  static const String locale = 'locale';
  static const String refreshToken = 'refreshToken';
  static const String favoriteProductIds = 'favorite_product_ids';
  static const String browseHistory = 'browse_history';
}

/// 动画时常常量
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 300);
}
