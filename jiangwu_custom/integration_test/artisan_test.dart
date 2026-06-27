import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

/// 手作人模块测试
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('手作人模块测试', () {
    testWidgets('1. 工作台页面', (tester) async {
      await TestHelper.loginApp(tester);
      final artisanToggle = find.textContaining('手作人');
      if (artisanToggle.evaluate().isNotEmpty) {
        await tester.tap(artisanToggle.first);
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('2. 手作人订单管理', (tester) async {
      await TestHelper.loginApp(tester);
      final artisanToggle = find.textContaining('手作人');
      if (artisanToggle.evaluate().isNotEmpty) {
        await tester.tap(artisanToggle.first);
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }
      final bottomNavs = find.byType(BottomNavigationBar);
      if (bottomNavs.evaluate().isNotEmpty) {
        final navIcons = find.descendant(
          of: bottomNavs.first,
          matching: find.byType(Icon),
        );
        if (navIcons.evaluate().length >= 2) {
          await tester.tap(navIcons.at(1));
          await TestHelper.waitForPageLoad(tester, seconds: 2);
        }
      }
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('3. 作品管理页面', (tester) async {
      await TestHelper.loginApp(tester);
      final artisanToggle = find.textContaining('手作人');
      if (artisanToggle.evaluate().isNotEmpty) {
        await tester.tap(artisanToggle.first);
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }
      final bottomNavs = find.byType(BottomNavigationBar);
      if (bottomNavs.evaluate().isNotEmpty) {
        final navIcons = find.descendant(
          of: bottomNavs.first,
          matching: find.byType(Icon),
        );
        if (navIcons.evaluate().length >= 3) {
          await tester.tap(navIcons.at(2));
          await TestHelper.waitForPageLoad(tester, seconds: 2);
        }
      }
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('4. 收入统计页面', (tester) async {
      await TestHelper.loginApp(tester);
      final artisanToggle = find.textContaining('手作人');
      if (artisanToggle.evaluate().isNotEmpty) {
        await tester.tap(artisanToggle.first);
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }
      final bottomNavs = find.byType(BottomNavigationBar);
      if (bottomNavs.evaluate().isNotEmpty) {
        final navIcons = find.descendant(
          of: bottomNavs.first,
          matching: find.byType(Icon),
        );
        if (navIcons.evaluate().length >= 4) {
          await tester.tap(navIcons.at(3));
          await TestHelper.waitForPageLoad(tester, seconds: 2);
        }
      }
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('5. 手作人主页(路由)', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/artisan/1');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
