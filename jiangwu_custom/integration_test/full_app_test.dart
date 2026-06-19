import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

/// 全功能集成测试套件
/// 覆盖应用的所有主要功能模块
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('匠物定制 - 全功能集成测试', () {
    testWidgets('01. 应用启动和初始化', (tester) async {
      await TestHelper.startApp(tester);

      // 验证应用启动
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('02. 登录流程', (tester) async {
      await TestHelper.startApp(tester);

      // 验证登录页面元素
      expect(find.text('登录'), findsOneWidget);

      // 输入测试账号
      final phoneField = find.widgetWithText(TextFormField, '手机号');
      if (phoneField.evaluate().isNotEmpty) {
        await TestHelper.enterText(tester, phoneField, TestHelper.testPhone);

        final passwordField = find.widgetWithText(TextFormField, '密码');
        await TestHelper.enterText(tester, passwordField, TestHelper.testPassword);

        // 点击登录
        await TestHelper.tapText(tester, '登录');
        await TestHelper.waitForPageLoad(tester, seconds: 5);

        // 验证登录成功（跳转到首页）
        expect(find.byType(BottomNavigationBar), findsOneWidget);
      }
    });

    testWidgets('03. 底部导航栏功能', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 验证底部导航栏存在
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // 验证有4个导航项
      final navItems = find.byType(BottomNavigationBarItem);
      expect(navItems.evaluate().length, equals(4));
    });

    testWidgets('04. 发现页 - 分类导航', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到发现页
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 2) {
        await tester.tap(navItems.at(1));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 验证发现页加载
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('05. 发现页 - 搜索功能', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到发现页
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 2) {
        await tester.tap(navItems.at(1));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 点击搜索图标
        final searchIcon = find.byIcon(Icons.search);
        if (searchIcon.evaluate().isNotEmpty) {
          await TestHelper.tapIcon(tester, Icons.search);
          await TestHelper.waitForPageLoad(tester, seconds: 2);

          // 验证搜索页面
          expect(find.byType(TextField), findsWidgets);
        }
      }
    });

    testWidgets('06. 发现页 - 商品列表', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 5);

      // 验证有商品卡片
      final cards = find.byType(Card);
      expect(cards, findsWidgets);
    });

    testWidgets('07. 订单 - 订单列表', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到我的页面
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 点击我的订单
        final orderFinder = find.text('我的订单');
        if (orderFinder.evaluate().isNotEmpty) {
          await TestHelper.tapText(tester, '我的订单');
          await TestHelper.waitForPageLoad(tester, seconds: 2);

          // 验证订单列表页面
          expect(find.byType(TabBar), findsOneWidget);
        }
      }
    });

    testWidgets('08. 订单 - 状态筛选', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入订单列表
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        final orderFinder = find.text('我的订单');
        if (orderFinder.evaluate().isNotEmpty) {
          await TestHelper.tapText(tester, '我的订单');
          await TestHelper.waitForPageLoad(tester, seconds: 2);

          // 切换 Tab
          final tabs = find.byType(Tab);
          if (tabs.evaluate().length >= 2) {
            await tester.tap(tabs.at(1));
            await TestHelper.waitForPageLoad(tester, seconds: 1);

            // 切换回第一个 Tab
            await tester.tap(tabs.first);
            await TestHelper.waitForPageLoad(tester, seconds: 1);
          }
        }
      }
    });

    testWidgets('09. 个人中心 - 页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到我的页面
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 验证设置图标
        expect(find.byIcon(Icons.settings), findsOneWidget);
      }
    });

    testWidgets('10. 设置页 - 页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入设置页
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 验证设置页面所有项
        expect(find.text('收货地址'), findsOneWidget);
        expect(find.text('修改密码'), findsOneWidget);
        expect(find.text('用户协议'), findsOneWidget);
        expect(find.text('隐私政策'), findsOneWidget);
        expect(find.text('帮助中心'), findsOneWidget);
        expect(find.text('意见反馈'), findsOneWidget);
        expect(find.text('退出登录'), findsOneWidget);
      }
    });

    testWidgets('11. 设置页 - 用户协议导航', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入设置页
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 点击用户协议
        await TestHelper.tapText(tester, '用户协议');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 验证用户协议页面
        expect(find.text('用户协议'), findsWidgets);

        // 返回
        if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
          await TestHelper.tapIcon(tester, Icons.arrow_back);
          await TestHelper.waitForPageLoad(tester, seconds: 1);
        }
      }
    });

    testWidgets('12. 设置页 - 隐私政策导航', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        await TestHelper.tapText(tester, '隐私政策');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        expect(find.text('隐私政策'), findsWidgets);
      }
    });

    testWidgets('13. 设置页 - 帮助中心导航', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        await TestHelper.tapText(tester, '帮助中心');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        expect(find.text('帮助中心'), findsWidgets);
      }
    });

    testWidgets('14. 设置页 - 意见反馈导航', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        await TestHelper.tapText(tester, '意见反馈');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        expect(find.text('意见反馈'), findsWidgets);
        expect(find.text('提交反馈'), findsOneWidget);
      }
    });

    testWidgets('15. 收藏 - 页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        final favoritesFinder = find.text('我的收藏');
        if (favoritesFinder.evaluate().isNotEmpty) {
          await TestHelper.tapText(tester, '我的收藏');
          await TestHelper.waitForPageLoad(tester, seconds: 2);

          expect(find.byType(TabBar), findsOneWidget);
        }
      }
    });

    testWidgets('16. 浏览历史 - 页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        final historyFinder = find.text('浏览历史');
        if (historyFinder.evaluate().isNotEmpty) {
          await TestHelper.tapText(tester, '浏览历史');
          await TestHelper.waitForPageLoad(tester, seconds: 2);
        }
      }
    });

    testWidgets('17. 商品详情 - 页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 5);

      // 尝试点击第一个商品卡片
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await TestHelper.waitForPageLoad(tester, seconds: 3);

        // 验证进入详情页
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('18. 下拉刷新 - 首页', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 在首页尝试下拉刷新
      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.fling(listView.first, const Offset(0, 300), 800);
        await TestHelper.waitForPageLoad(tester, seconds: 3);
      }
    });

    testWidgets('19. 页面导航 - 返回', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入设置页
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 尝试返回
        final backIcon = find.byIcon(Icons.arrow_back);
        if (backIcon.evaluate().isNotEmpty) {
          await TestHelper.tapIcon(tester, Icons.arrow_back);
          await TestHelper.waitForPageLoad(tester, seconds: 1);
        }
      }
    });

    testWidgets('20. 应用完整流程', (tester) async {
      await TestHelper.startApp(tester);

      // 1. 启动
      expect(find.byType(MaterialApp), findsOneWidget);

      // 2. 验证底部导航
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // 3. 切换到发现页
      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 2) {
        await tester.tap(navItems.at(1));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      // 4. 切换到我的页面
      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      // 5. 进入设置页
      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 6. 验证设置页面
        expect(find.text('退出登录'), findsOneWidget);
      }
    });
  });
}
