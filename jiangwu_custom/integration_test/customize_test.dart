import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

/// 定制模块测试
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('定制模块测试', () {
    testWidgets('1. 发布需求页面(底部tab)', (tester) async {
      await TestHelper.loginApp(tester);
      final navIcons = find.descendant(
        of: find.byType(BottomNavigationBar).first,
        matching: find.byType(Icon),
      );
      if (navIcons.evaluate().length >= 3) {
        await tester.tap(navIcons.at(2));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('2. 发布需求页面(路由)', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/customize/publish');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('3. 3D预览页面', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/customize/preview', arguments: {'material': '陶瓷', 'size': '中等', 'color': '白色'});
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('4. 方案确认页面', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/customize/confirm', arguments: {'material': '陶瓷', 'size': '中等', 'color': '白色'});
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
