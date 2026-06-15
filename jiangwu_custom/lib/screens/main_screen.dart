import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/discover/discover_screen.dart';
import '../../screens/customize/publish_screen.dart';
import '../../screens/order/order_list_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/artisan/work_screen.dart';

/// 主页面容器
/// 包含底部导航栏，切换不同功能模块
/// 支持切换买家/手作人模式

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isArtisanMode = false;

  // 买家模式页面
  final List<Widget> _customerScreens = const [
    HomeScreen(),
    DiscoverScreen(),
    PublishScreen(),
    OrderListScreen(),
    ProfileScreen(),
  ];

  // 手作人模式页面
  final List<Widget> _artisanScreens = const [
    WorkScreen(),
    OrderManageScreen(),
    ProductManageScreen(),
    IncomeScreen(),
    ProfileScreen(),
  ];

  List<Widget> get _screens =>
      _isArtisanMode ? _artisanScreens : _customerScreens;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isArtisanMode ? '匠物定制 · 手作人' : '匠物定制'),
        actions: [
          // 模式切换按钮
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingMedium),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isArtisanMode = !_isArtisanMode;
                  _currentIndex = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingSmall,
                  vertical: AppSizes.spacingXSmall,
                ),
                decoration: BoxDecoration(
                  color: _isArtisanMode
                      ? AppColors.brown
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isArtisanMode ? Icons.work : Icons.shopping_bag,
                      size: 14,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: AppSizes.spacingXSmall),
                    Text(
                      _isArtisanMode ? '手作人' : '买家',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _isArtisanMode
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: '工作台',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: '订单',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_outlined),
                  activeIcon: Icon(Icons.inventory),
                  label: '作品',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: '收入',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: '我的',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: '首页',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: '发现',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle),
                  label: '发布',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: '订单',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: '我的',
                ),
              ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
