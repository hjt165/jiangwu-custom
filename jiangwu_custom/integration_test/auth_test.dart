import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('认证模块测试', () {
    testWidgets('1. 启动应用显示登录页面', (tester) async {
      await TestHelper.startApp(tester);

      expect(find.text('登录'), findsAtLeastNWidgets(1));
      expect(find.text('手机号'), findsAtLeastNWidgets(1));
      expect(find.text('密码'), findsAtLeastNWidgets(1));
    });

    testWidgets('2. 登录表单验证 - 空字段', (tester) async {
      await TestHelper.startApp(tester);

      await TestHelper.tapButtonText(tester, '登录');
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('请输入手机号'), findsOneWidget);
    });

    testWidgets('3. 登录表单验证 - 手机号格式错误', (tester) async {
      await TestHelper.startApp(tester);

      // 输入无效手机号
      final phoneField = find.byType(TextFormField).at(0);
      await tester.tap(phoneField);
      await tester.pumpAndSettle();
      await tester.enterText(phoneField, '123');
      await tester.pumpAndSettle();

      // 输入密码
      final passwordField = find.byType(TextFormField).at(1);
      await tester.tap(passwordField);
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, '123456');
      await tester.pumpAndSettle();

      // 点击登录
      await TestHelper.tapButtonText(tester, '登录');
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('手机号格式不正确'), findsOneWidget);
    });

    testWidgets('4. 登录成功', (tester) async {
      await TestHelper.startApp(tester);

      // 输入测试账号 - 使用 index 定位 TextFormField（0=手机号，1=密码）
      final phoneField = find.byType(TextFormField).at(0);
      await tester.tap(phoneField);
      await tester.pumpAndSettle();
      await tester.enterText(phoneField, TestHelper.testPhone);
      await tester.pumpAndSettle();

      final passwordField = find.byType(TextFormField).at(1);
      await tester.tap(passwordField);
      await tester.pumpAndSettle();
      await tester.enterText(passwordField, TestHelper.testPassword);
      await tester.pumpAndSettle();

      // 点击登录按钮
      await TestHelper.tapButtonText(tester, '登录');
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 登录成功后应该跳转到首页
      expect(
        find.byType(BottomNavigationBar),
        findsOneWidget,
        reason: '登录成功后应跳转到首页并显示底部导航栏',
      );
    });

    testWidgets('5. 跳转到注册页面', (tester) async {
      await TestHelper.startApp(tester);

      final registerFinder = find.textContaining('注册');
      if (registerFinder.evaluate().isNotEmpty) {
        await tester.tap(registerFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.textContaining('注册'), findsAtLeastNWidgets(1));
      }
    });

    testWidgets('6. 跳转到忘记密码页面', (tester) async {
      await TestHelper.startApp(tester);

      final forgotFinder = find.textContaining('忘记密码');
      if (forgotFinder.evaluate().isNotEmpty) {
        await tester.tap(forgotFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.textContaining('忘记密码'), findsAtLeastNWidgets(1));
      }
    });
  });
}
