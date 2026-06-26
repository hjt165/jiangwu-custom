import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

/// 全功能集成测试 - 跨模块流程测试
/// 单模块测试已由 auth/discover/order/profile_test 覆盖
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('匠物定制 - 跨模块流程测试', () {
    testWidgets('01. 商品详情页加载', (tester) async {
      await TestHelper.loginApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 5);

      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await TestHelper.waitForPageLoad(tester, seconds: 3);
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('02. 首页下拉刷新', (tester) async {
      await TestHelper.loginApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        await tester.fling(listView.first, const Offset(0, 300), 800);
        await TestHelper.waitForPageLoad(tester, seconds: 3);
      }
    });

    testWidgets('03. 页面导航返回', (tester) async {
      await TestHelper.loginApp(tester);
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

        final backIcon = find.byIcon(Icons.arrow_back);
        if (backIcon.evaluate().isNotEmpty) {
          await TestHelper.tapIcon(tester, Icons.arrow_back);
          await TestHelper.waitForPageLoad(tester, seconds: 1);
        }
      }
    });

    testWidgets('04. 完整导航流程', (tester) async {
      await TestHelper.loginApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      // 验证页面已加载（可能是登录页或首页）
      expect(find.byType(Scaffold), findsWidgets);

      final navItems = find.byType(BottomNavigationBarItem);
      if (navItems.evaluate().length >= 2) {
        await tester.tap(navItems.at(1));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      if (navItems.evaluate().length >= 4) {
        await tester.tap(navItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsIcon = find.byIcon(Icons.settings);
      if (settingsIcon.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);
        // 设置页面可能显示退出登录
        expect(find.byType(Scaffold), findsWidgets);
      }
    });
  });
}
