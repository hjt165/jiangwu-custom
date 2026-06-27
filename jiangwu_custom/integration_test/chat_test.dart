import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'helpers/test_helper.dart';

/// 聊天模块测试
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('聊天模块测试', () {
    testWidgets('1. 聊天列表页面(路由)', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/chat/list');
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('2. 聊天详情页面(路由)', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/chat/test_convo', arguments: {
        'conversationId': 'test_conversation',
        'otherName': '测试手作人',
        'otherAvatar': '',
      });
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('3. 消息中心入口', (tester) async {
      await TestHelper.loginApp(tester);
      final navigatorState = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigatorState.pushNamed('/chat/list');
      await tester.pumpAndSettle(const Duration(seconds: 3));
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);
    });
  });
}
