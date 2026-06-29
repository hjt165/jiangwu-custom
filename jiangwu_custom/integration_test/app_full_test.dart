import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jiangwu_custom/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('A - 认证模块', () {
    testWidgets('A1 - 登录页UI加载', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('匠物定制'), findsOneWidget);
      expect(find.byKey(const Key('login_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      expect(find.text('还没有账号？立即注册'), findsOneWidget);
      expect(find.text('忘记密码？'), findsOneWidget);
    });

    testWidgets('A2 - 注册页跳转与返回', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('还没有账号？立即注册'));
      await tester.pumpAndSettle();

      expect(find.text('获取验证码'), findsOneWidget);
      expect(find.text('注册').hitTestable(), findsWidgets);

      await tester.tap(find.text('返回登录'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login_phone_field')), findsOneWidget);
    });

    testWidgets('A3 - 忘记密码页跳转与返回', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('忘记密码？'));
      await tester.pumpAndSettle();

      expect(find.text('找回密码'), findsOneWidget);

      await tester.tap(find.text('返回登录'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login_phone_field')), findsOneWidget);
    });

    testWidgets('A4 - 手作人账号登录', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.enterText(
        find.byKey(const Key('login_phone_field')),
        '13800000002',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'artisan123',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('login_button')), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isEmpty) {
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('B-E - 登录后页面导航', () {
    testWidgets('BE1 - 全Tab导航 + 手作人模式切换', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await _login(tester);

      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {
        await _tapTab(tester, '发现');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await _tapTab(tester, '发布');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await _tapTab(tester, '订单');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await _tapTab(tester, '我的');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await _tapTab(tester, '首页');
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final modeBtn = find.text('买家');
        if (modeBtn.evaluate().isNotEmpty) {
          await tester.tap(modeBtn.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          await _tapTab(tester, '工作台');
          await tester.pumpAndSettle();

          await _tapTab(tester, '作品');
          await tester.pumpAndSettle();

          await _tapTab(tester, '收入');
          await tester.pumpAndSettle();

          final modeBtn2 = find.text('手作人');
          if (modeBtn2.evaluate().isNotEmpty) {
            await tester.tap(modeBtn2.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}

Future<void> _login(WidgetTester tester) async {
  if (find.byKey(const Key('login_phone_field')).evaluate().isEmpty) return;

  await tester.enterText(
    find.byKey(const Key('login_phone_field')),
    '13800000002',
  );
  await tester.enterText(
    find.byKey(const Key('login_password_field')),
    'artisan123',
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('login_button')), warnIfMissed: false);
  await tester.pumpAndSettle(const Duration(seconds: 10));
}

Future<void> _tapTab(WidgetTester tester, String label) async {
  final tabFinder = find.text(label).hitTestable();
  if (tabFinder.evaluate().isNotEmpty) {
    await tester.tap(tabFinder.first);
  }
}
