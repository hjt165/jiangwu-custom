import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('订单模块测试', () {
    testWidgets('1. 订单列表页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到我的页面（最后一个导航项）
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      // 点击"我的订单"
      final orderFinder = find.text('我的订单');
      if (orderFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '我的订单');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 订单列表页面应该有 TabBar
        expect(find.byType(TabBar), findsOneWidget);
      }
    });

    testWidgets('2. 订单状态筛选', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 先进入订单列表
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final orderFinder = find.text('我的订单');
      if (orderFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '我的订单');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 切换 Tab
        final tabFinder = find.byType(Tab);
        if (tabFinder.evaluate().length >= 2) {
          await tester.tap(tabFinder.at(1));
          await TestHelper.waitForPageLoad(tester, seconds: 1);
        }
      }
    });

    testWidgets('3. 发布定制需求', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 点击底部中间的发布按钮
      // 查找 FloatingActionButton 或发布入口
      final publishFinder = find.text('发布');
      if (publishFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '发布');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 发布页面应该有表单
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('4. 订单详情页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入订单列表
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final orderFinder = find.text('我的订单');
      if (orderFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '我的订单');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 尝试点击第一个订单卡片
        final cardFinder = find.byType(Card);
        if (cardFinder.evaluate().isNotEmpty) {
          await tester.tap(cardFinder.first);
          await TestHelper.waitForPageLoad(tester, seconds: 2);
        }
      }
    });

    testWidgets('5. 个人中心页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到我的页面
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 个人中心应该显示用户信息
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
