import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jiangwu_custom/app/app.dart';

final testNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: JiangwuApp(navigatorKey: testNavigatorKey),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    // Advance past the splash screen 1-second timer
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('App has correct title and theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: JiangwuApp(navigatorKey: testNavigatorKey),
      ),
    );
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, '匠物定制');
    expect(materialApp.debugShowCheckedModeBanner, false);
    expect(materialApp.theme, isNotNull);

    // Advance past the splash screen timer
    await tester.pump(const Duration(seconds: 1));
  });
}
