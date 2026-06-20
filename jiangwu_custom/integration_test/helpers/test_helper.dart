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
  static const String testPhone = '13800000003';
  static const String testPassword = '123456';
  static String get baseUrl => kIsWeb ? 'http://localhost:8080/api' : 'http://10.0.2.2:8080/api';

  /// 等待页面加载完成
  static Future<void> waitForPageLoad(WidgetTester tester, {int seconds = 3}) async {
    await tester.pumpAndSettle(Duration(seconds: seconds));
  }

  /// 查找并点击指定文本的 Widget
  static Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    expect(finder, findsOneWidget, reason: '找不到文本: $text');
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// 查找并点击指定 Icon 的 Widget
  static Future<void> tapIcon(WidgetTester tester, IconData icon) async {
    final finder = find.byIcon(icon);
    expect(finder, findsOneWidget, reason: '找不到图标: $icon');
    await tester.tap(finder);
    await tester.pumpAndSettle();
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

  /// 启动应用
  static Future<void> startApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
}
