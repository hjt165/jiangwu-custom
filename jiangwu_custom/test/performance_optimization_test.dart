import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:jiangwu_custom/widgets/common/image_widget.dart';
import 'package:jiangwu_custom/app/constants.dart';

void main() {
  group('ImageWidget', () {
    testWidgets('renders with network image', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ImageWidget(
            imageUrl: 'https://example.com/test.jpg',
            width: 100,
            height: 100,
          ),
        ),
      ));
      expect(find.byType(ImageWidget), findsOneWidget);
    });

    testWidgets('renders with empty url', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ImageWidget(
            imageUrl: '',
            width: 100,
            height: 100,
          ),
        ),
      ));
      expect(find.byType(ImageWidget), findsOneWidget);
    });
  });

  group('AppColors', () {
    test('primary color', () {
      expect(AppColors.primary, const Color(0xFF2C3E50));
    });

    test('accent color', () {
      expect(AppColors.accent, const Color(0xFFE74C3C));
    });

    test('background color', () {
      expect(AppColors.background, const Color(0xFFF5F5F0));
    });
  });

  group('AppSizes', () {
    test('radiusSmall is 8', () {
      expect(AppSizes.radiusSmall, 8.0);
    });

    test('radiusMedium is 12', () {
      expect(AppSizes.radiusMedium, 12.0);
    });

    test('paddingSmall is 8', () {
      expect(AppSizes.paddingSmall, 8.0);
    });

    test('paddingMedium is 16', () {
      expect(AppSizes.paddingMedium, 16.0);
    });

    test('cardShadow has 1 element', () {
      expect(AppSizes.cardShadow.length, 1);
    });
  });
}
