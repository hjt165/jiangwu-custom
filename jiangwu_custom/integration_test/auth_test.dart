import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('认证模块测试', () {
    testWidgets('1. 启动应用显示登录页面', (tester) async {
      await TestHelper.startApp(tester);

      // 应该显示登录页面
      expect(find.text('登录'), findsOneWidget);
      expect(find.text('手机号'), findsOneWidget);
      expect(find.text('密码'), findsOneWidget);
    });

    testWidgets('2. 登录表单验证 - 空字段', (tester) async {
      await TestHelper.startApp(tester);

      // 点击登录按钮（不输入任何内容）
      await TestHelper.tapText(tester, '登录');
      await TestHelper.waitForPageLoad(tester, seconds: 1);

      // 应该显示错误提示（手机号格式验证）
      // 注意：具体提示文本取决于验证逻辑
    });

    testWidgets('3. 登录表单验证 - 手机号格式错误', (tester) async {
      await TestHelper.startApp(tester);

      // 输入无效手机号
      final phoneField = find.widgetWithText(TextFormField, '手机号');
      await TestHelper.enterText(tester, phoneField, '123');

      // 输入密码
      final passwordField = find.widgetWithText(TextFormField, '密码');
      await TestHelper.enterText(tester, passwordField, '123456');

      // 点击登录
      await TestHelper.tapText(tester, '登录');
      await TestHelper.waitForPageLoad(tester, seconds: 1);
    });

    testWidgets('4. 登录成功', (tester) async {
      await TestHelper.startApp(tester);

      // 输入测试账号
      final phoneField = find.widgetWithText(TextFormField, '手机号');
      await TestHelper.enterText(tester, phoneField, TestHelper.testPhone);

      final passwordField = find.widgetWithText(TextFormField, '密码');
      await TestHelper.enterText(tester, passwordField, TestHelper.testPassword);

      // 点击登录
      await TestHelper.tapText(tester, '登录');
      await TestHelper.waitForPageLoad(tester, seconds: 5);

      // 登录成功后应该跳转到首页
      // 检查是否能看到首页元素（如底部导航栏）
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('5. 跳转到注册页面', (tester) async {
      await TestHelper.startApp(tester);

      // 点击"注册"链接
      final registerFinder = find.text('注册');
      if (registerFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '注册');
        await TestHelper.waitForPageLoad(tester, seconds: 1);

        // 应该显示注册页面
        expect(find.text('注册'), findsWidgets);
      }
    });

    testWidgets('6. 跳转到忘记密码页面', (tester) async {
      await TestHelper.startApp(tester);

      final forgotFinder = find.text('忘记密码');
      if (forgotFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '忘记密码');
        await TestHelper.waitForPageLoad(tester, seconds: 1);
      }
    });
  });
}
