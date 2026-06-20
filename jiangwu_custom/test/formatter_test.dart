import 'package:flutter_test/flutter_test.dart';
import 'package:jiangwu_custom/utils/formatter.dart';

void main() {
  group('Formatter.formatAmount', () {
    test('returns 0.00 for null', () {
      expect(Formatter.formatAmount(null), '0.00');
    });

    test('formats double correctly', () {
      expect(Formatter.formatAmount(123.456), '123.46');
      expect(Formatter.formatAmount(0.0), '0.00');
      expect(Formatter.formatAmount(100.0), '100.00');
    });

    test('formats string number correctly', () {
      expect(Formatter.formatAmount('99.9'), '99.90');
      expect(Formatter.formatAmount('abc'), '0.00');
    });

    test('formats int correctly', () {
      expect(Formatter.formatAmount(50), '50.00');
    });
  });

  group('Formatter.formatAmountWithSymbol', () {
    test('adds yuan symbol', () {
      expect(Formatter.formatAmountWithSymbol(100), '¥100.00');
      expect(Formatter.formatAmountWithSymbol(null), '¥0.00');
    });
  });

  group('Formatter.formatAmountWithCommas', () {
    test('adds commas for thousands', () {
      expect(Formatter.formatAmountWithCommas(1234567.89), '1,234,567.89');
      expect(Formatter.formatAmountWithCommas(999), '999.00');
      expect(Formatter.formatAmountWithCommas(1000), '1,000.00');
    });

    test('handles null', () {
      expect(Formatter.formatAmountWithCommas(null), '0.00');
    });
  });

  group('Formatter.maskPhone', () {
    test('masks middle digits', () {
      expect(Formatter.maskPhone('13888888888'), '138****8888');
    });

    test('returns original if too short', () {
      expect(Formatter.maskPhone('123'), '123');
    });
  });

  group('Formatter.maskName', () {
    test('masks after first character', () {
      expect(Formatter.maskName('张三'), '张*');
      expect(Formatter.maskName('欧阳锋'), '欧*');
    });

    test('returns original for single character', () {
      expect(Formatter.maskName('张'), '张');
    });
  });

  group('Formatter.formatFileSize', () {
    test('formats bytes', () {
      expect(Formatter.formatFileSize(500), '500 B');
    });

    test('formats kilobytes', () {
      expect(Formatter.formatFileSize(1536), '1.5 KB');
    });

    test('formats megabytes', () {
      expect(Formatter.formatFileSize(1048576), '1.0 MB');
    });

    test('formats gigabytes', () {
      expect(Formatter.formatFileSize(1073741824), '1.0 GB');
    });
  });

  group('Formatter.formatNumber', () {
    test('returns original for small numbers', () {
      expect(Formatter.formatNumber(999), '999');
    });

    test('formats wan (ten thousand)', () {
      expect(Formatter.formatNumber(10000), '1万');
      expect(Formatter.formatNumber(15000), '1.5万');
      expect(Formatter.formatNumber(99999999), '10000.0万');
    });
  });

  group('Formatter.formatDuration', () {
    test('formats seconds to mm:ss', () {
      expect(Formatter.formatDuration(90), '01:30');
      expect(Formatter.formatDuration(0), '00:00');
      expect(Formatter.formatDuration(3661), '61:01');
    });
  });

  group('Formatter.formatDurationWithUnit', () {
    test('formats with Chinese units', () {
      expect(Formatter.formatDurationWithUnit(90), '1分30秒');
      expect(Formatter.formatDurationWithUnit(30), '30秒');
      expect(Formatter.formatDurationWithUnit(120), '2分钟');
    });
  });

  group('Formatter.formatPhone', () {
    test('adds spaces to 11-digit phone', () {
      expect(Formatter.formatPhone('13888888888'), '138 8888 8888');
    });

    test('returns original for non-11 digits', () {
      expect(Formatter.formatPhone('123'), '123');
    });
  });

  group('Formatter.formatOrderNo', () {
    test('adds space after 10 chars', () {
      expect(Formatter.formatOrderNo('JW20260614001'), 'JW20260614 001');
    });

    test('returns original if too short', () {
      expect(Formatter.formatOrderNo('JW123'), 'JW123');
    });
  });
}
