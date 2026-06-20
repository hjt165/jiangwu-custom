import 'package:flutter_test/flutter_test.dart';
import 'package:jiangwu_custom/utils/date_utils.dart';

void main() {
  group('AppDateUtils.formatDate', () {
    test('formats date to yyyy-MM-dd', () {
      final date = DateTime(2026, 6, 15, 10, 30, 0);
      expect(AppDateUtils.formatDate(date), '2026-06-15');
    });
  });

  group('AppDateUtils.formatTime', () {
    test('formats time to HH:mm', () {
      final date = DateTime(2026, 6, 15, 9, 5, 0);
      expect(AppDateUtils.formatTime(date), '09:05');
    });
  });

  group('AppDateUtils.formatMonthDay', () {
    test('formats to MM-dd', () {
      final date = DateTime(2026, 12, 25);
      expect(AppDateUtils.formatMonthDay(date), '12-25');
    });
  });

  group('AppDateUtils.relativeTime', () {
    test('returns 刚刚 for less than 60 seconds', () {
      final now = DateTime.now();
      expect(AppDateUtils.relativeTime(now), '刚刚');
      expect(AppDateUtils.relativeTime(now.subtract(const Duration(seconds: 30))), '刚刚');
    });

    test('returns minutes ago', () {
      final now = DateTime.now();
      expect(AppDateUtils.relativeTime(now.subtract(const Duration(minutes: 5))), '5分钟前');
    });

    test('returns hours ago', () {
      final now = DateTime.now();
      expect(AppDateUtils.relativeTime(now.subtract(const Duration(hours: 3))), '3小时前');
    });

    test('returns days ago', () {
      final now = DateTime.now();
      expect(AppDateUtils.relativeTime(now.subtract(const Duration(days: 2))), '2天前');
    });
  });

  group('AppDateUtils.isToday', () {
    test('returns true for today', () {
      expect(AppDateUtils.isToday(DateTime.now()), true);
    });

    test('returns false for yesterday', () {
      expect(AppDateUtils.isToday(DateTime.now().subtract(const Duration(days: 1))), false);
    });
  });

  group('AppDateUtils.isYesterday', () {
    test('returns true for yesterday', () {
      expect(AppDateUtils.isYesterday(DateTime.now().subtract(const Duration(days: 1))), true);
    });

    test('returns false for today', () {
      expect(AppDateUtils.isYesterday(DateTime.now()), false);
    });
  });

  group('AppDateUtils.toTimestamp / fromTimestamp', () {
    test('roundtrip conversion preserves value', () {
      final date = DateTime(2026, 6, 15, 12, 0, 0);
      final timestamp = AppDateUtils.toTimestamp(date);
      final restored = AppDateUtils.fromTimestamp(timestamp);
      expect(restored.year, date.year);
      expect(restored.month, date.month);
      expect(restored.day, date.day);
      expect(restored.hour, date.hour);
      expect(restored.minute, date.minute);
    });
  });

  group('AppDateUtils.daysBetween', () {
    test('returns 0 for same day', () {
      final date = DateTime(2026, 6, 15);
      expect(AppDateUtils.daysBetween(date, date), 0);
    });

    test('returns correct days', () {
      final from = DateTime(2026, 6, 10);
      final to = DateTime(2026, 6, 15);
      expect(AppDateUtils.daysBetween(from, to), 5);
      expect(AppDateUtils.daysBetween(to, from), -5);
    });
  });

  group('AppDateUtils.parse', () {
    test('parses valid date string', () {
      final result = AppDateUtils.parse('2026-06-15 10:30:00');
      expect(result, isNotNull);
      expect(result!.year, 2026);
      expect(result.month, 6);
      expect(result.day, 15);
    });

    test('returns null for invalid string', () {
      expect(AppDateUtils.parse('not-a-date'), isNull);
    });

    test('parses with custom format', () {
      final result = AppDateUtils.parse('15/06/2026', format: 'dd/MM/yyyy');
      expect(result, isNotNull);
      expect(result!.day, 15);
    });
  });
}
