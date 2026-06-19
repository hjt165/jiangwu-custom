import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('发现模块测试', () {
    testWidgets('1. 首页加载和展示', (tester) async {
      await TestHelper.startApp(tester);

      // 首页应该加载完成
      await TestHelper.waitForPageLoad(tester, seconds: 5);

      // 检查底部导航栏
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('2. 底部导航切换', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 点击发现页（第二个导航项）
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 2) {
        await tester.tap(bottomNavItems.at(1));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }
    });

    testWidgets('3. 分类页面加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到发现页
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 2) {
        await tester.tap(bottomNavItems.at(1));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      // 查找分类入口
      final categoryFinder = find.text('全部分类');
      if (categoryFinder.evaluate().isNotEmpty) {
        await TestHelper.tapText(tester, '全部分类');
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 分类页面应该显示分类列表
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('4. 搜索页面', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 切换到发现页
      final bottomNavItems = find.byType(BottomNavigationBarItem);
      if (bottomNavItems.evaluate().length >= 2) {
        await tester.tap(bottomNavItems.at(1));
        await TestHelper.waitForPageLoad(tester, seconds: 2);
      }

      // 查找搜索入口
      final searchFinder = find.byIcon(Icons.search);
      if (searchFinder.evaluate().isNotEmpty) {
        await TestHelper.tapIcon(tester, Icons.search);
        await TestHelper.waitForPageLoad(tester, seconds: 2);

        // 搜索页面应该有搜索输入框
        expect(find.byType(TextField), findsWidgets);
      }
    });

    testWidgets('5. 商品列表加载', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 5);

      // 检查是否有商品相关的 Widget
      // 首页应该有精选商品
      final商品卡片 = find.byType(Card);
      expect(商品卡片, findsWidgets);
    });

    testWidgets('6. 下拉刷新', (tester) async {
      await TestHelper.startApp(tester);
      await TestHelper.waitForPageLoad(tester, seconds: 3);

      // 在首页尝试下拉刷新
      await tester.fling(find.byType(ListView).first, const Offset(0, 300), 800);
      await TestHelper.waitForPageLoad(tester, seconds: 3);
    });
  });
}
