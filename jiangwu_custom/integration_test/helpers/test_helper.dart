import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiangwu_custom/main.dart' as app;

export 'package:integration_test/integration_test.dart';

/// 测试工具类
class TestHelper {
  static const String testPhone = '13800000000';
  static const String testPassword = 'admin123';
  static String get baseUrl => kIsWeb ? 'http://localhost:8080/api' : 'http://10.0.2.2:8080/api';

  /// 等待页面加载完成
  static Future<void> waitForPageLoad(WidgetTester tester, {int seconds = 3}) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  /// 查找并点击指定文本的 Widget（允许多个匹配，点击第一个）
  static Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    expect(finder, findsAtLeastNWidgets(1), reason: '找不到文本: $text');
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  /// 查找并点击指定 Icon 的 Widget
  static Future<void> tapIcon(WidgetTester tester, IconData icon) async {
    final finder = find.byIcon(icon);
    expect(finder, findsAtLeastNWidgets(1), reason: '找不到图标: $icon');
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  /// 点击指定按钮内的文本
  static Future<void> tapButtonText(WidgetTester tester, String text) async {
    final finder = find.widgetWithText(ElevatedButton, text);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
    } else {
      await tapText(tester, text);
    }
  }

  /// 在输入框中输入文本
  static Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// 查找 TextFormField 并输入
  static Future<void> enterTextInField(WidgetTester tester, String labelText, String text) async {
    final finder = find.widgetWithText(TextFormField, labelText);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await tester.enterText(finder, text);
      await tester.pumpAndSettle();
    }
  }

  /// 滑动到指定位置
  static Future<void> scrollUntilVisible(WidgetTester tester, Finder finder, {Finder? scrollable}) async {
    final scroll = scrollable ?? find.byType(ListView).first;
    await tester.scrollUntilVisible(finder, 100, scrollable: scroll);
    await tester.pumpAndSettle();
  }

  /// 等待指定文本出现
  static Future<void> waitForText(WidgetTester tester, String text, {int timeoutSeconds = 10}) async {
    final finder = find.text(text);
    int attempts = 0;
    while (finder.evaluate().isEmpty && attempts < timeoutSeconds * 2) {
      await tester.pump(const Duration(milliseconds: 500));
      attempts++;
    }
  }

  /// 启动应用并等待 Splash 跳转完成
  static Future<void> startApp(WidgetTester tester) async {
    // 清除持久化数据，确保每次测试从空白状态开始
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  /// 启动应用并自动登录，确保进入首页
  static Future<void> loginApp(WidgetTester tester) async {
    await startApp(tester);

    // 如果在登录页面，自动执行登录
    final phoneField = find.widgetWithText(TextFormField, '手机号');
    if (phoneField.evaluate().isNotEmpty) {
      await enterText(tester, phoneField, testPhone);

      final passwordField = find.widgetWithText(TextFormField, '密码');
      await enterText(tester, passwordField, testPassword);

      await tapButtonText(tester, '登录');
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
  }
}
