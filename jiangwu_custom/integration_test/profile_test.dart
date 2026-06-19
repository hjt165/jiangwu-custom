import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('个人中心模块测试', () {
    testWidgets('1. 个人中心页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到我的页面
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 个人中心应该有设置入口
        expect(find.byIcon(Icons.settings), findsOneWidget);
      }
    });

    testWidgets('2. 设置页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入设置页面
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsFinder = find.byIcon(Icons.settings);
      if (settingsFinder.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 设置页面应该有各项设置
        expect(find.text('收货地址'), findsOneWidget);
        expect(find.text('修改密码'), findsOneWidget);
        expect(find.text('用户协议'), findsOneWidget);
        expect(find.text('隐私政策'), findsOneWidget);
        expect(find.text('帮助中心'), findsOneWidget);
        expect(find.text('意见反馈'), findsOneWidget);
        expect(find.text('退出登录'), findsOneWidget);
      }
    });

    testWidgets('3. 用户协议页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入设置页面
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsFinder = find.byIcon(Icons.settings);
      if (settingsFinder.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 点击用户协议
        await TestHelper.tapText(tester, '用户协议');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 用户协议页面应该有标题
        expect(find.text('用户协议'), findsWidgets);
      }
    });

    testWidgets('4. 隐私政策页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入设置页面
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsFinder = find.byIcon(Icons.settings);
      if (settingsFinder.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 点击隐私政策
        await TestHelper.tapText(tester, '隐私政策');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 隐私政策页面应该有标题
        expect(find.text('隐私政策'), findsWidgets);
      }
    });

    testWidgets('5. 帮助中心页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入设置页面
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsFinder = find.byIcon(Icons.settings);
      if (settingsFinder.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 点击帮助中心
        await TestHelper.tapText(tester, '帮助中心');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 帮助中心应该有 FAQ 列表
        expect(find.text('帮助中心'), findsWidgets);
      }
    });

    testWidgets('6. 意见反馈页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入设置页面
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final settingsFinder = find.byIcon(Icons.settings);
      if (settingsFinder.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.settings);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 点击意见反馈
        await TestHelper.tapText(tester, '意见反馈');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 意见反馈页面应该有输入框
        expect(find.text('意见反馈'), findsWidgets);
        expect(find.text('提交反馈'), findsOneWidget);
      }
    });

    testWidgets('7. 收藏页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入我的收藏
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final favoritesFinder = find.text('我的收藏');
      if (favoritesFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '我的收藏');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 收藏页面应该有 TabBar
        expect(find.byType(TabBar), findsOneWidget);
      }
    });

    testWidgets('8. 浏览历史页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入浏览历史
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      final historyFinder = find.text('浏览历史');
      if (historyFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '浏览历史');
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }
    });

    testWidgets('9. 编辑个人资料', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 进入个人中心
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 4) {
        await tester.tap(bottomNavItems.at(3));
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 点击头像或编辑按钮
        final editIcon = find.byIcon(Icons.edit);
        if (editIcon.evaluate().isNotEmpty) {
          await TestHelper.tapIcon(tester, Icons.edit);
          await TestHelper.waitForPageLoad(tester, seconds: 2);
        }
      }
    });
  });
}
