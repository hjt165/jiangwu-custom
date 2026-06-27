import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

/// 订单扩展测试
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('订单扩展模块测试', () {
    testWidgets('1. 支付页面', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/customize/pay', arguments: 'test_order_1');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('2. 评价页面', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/order/test_order_1/review', arguments: 'test_order_1');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('3. 阶段确认页面', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/order/test_order_1/confirm', arguments: 'test_order_1');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
