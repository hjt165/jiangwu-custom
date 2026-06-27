import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

/// 个人中心扩展测试
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('个人中心扩展模块测试', () {
    testWidgets('1. 地址列表页面', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/profile/address-list');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('2. 新增地址页面', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/profile/address-edit');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('3. 修改密码页面', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/profile/change-password');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
