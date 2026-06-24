import 'package:intl/intl.dart';

/// 日期工具类
/// 提供日期格式化、相对时间等功能

class AppDateUtils {
  AppDateUtils._();

  // 日期格式
  static const String _fullFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String _dateFormat = 'yyyy-MM-dd';
  static const String _timeFormat = 'HH:mm:ss';
  static const String _shortTimeFormat = 'HH:mm';
  static const String _monthDayFormat = 'MM-dd';
  static const String _yearMonthFormat = 'yyyy-MM';

  /// 格式化日期时间
  static String formatDateTime(DateTime dateTime, {String? format}) {
    final formatter = DateFormat(format ?? _fullFormat);
    return formatter.format(dateTime);
  }

  /// 格式化日期
  static String formatDate(DateTime dateTime) {
    final formatter = DateFormat(_dateFormat);
    return formatter.format(dateTime);
  }

  /// 格式化时间
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat(_shortTimeFormat);
    return formatter.format(dateTime);
  }

  /// 格式化月日
  static String formatMonthDay(DateTime dateTime) {
    final formatter = DateFormat(_monthDayFormat);
    return formatter.format(dateTime);
  }

  /// 格式化年月
  static String formatYearMonth(DateTime dateTime) {
    final formatter = DateFormat(_yearMonthFormat);
    return formatter.format(dateTime);
  }

  /// 获取相对时间（"3分钟前"、"2小时前"等）
  static String relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  /// 获取相对时间（带"前缀"，如"3分钟前发布"）
  static String relativeTimeWithPrefix(DateTime dateTime, {String prefix = '前'}) {
    final relative = relativeTime(dateTime);
    return '$relative$prefix';
  }

  /// 判断是否是今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// 判断是否是昨天
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// 判断是否是今年
  static bool isThisYear(DateTime dateTime) {
    return dateTime.year == DateTime.now().year;
  }

  /// 智能格式化（今天显示时间，昨天显示"昨天 HH:mm"，其他显示完整日期）
  static String smartFormat(DateTime dateTime) {
    if (isToday(dateTime)) {
      return formatTime(dateTime);
    } else if (isYesterday(dateTime)) {
      return '昨天 ${formatTime(dateTime)}';
    } else if (isThisYear(dateTime)) {
      return formatMonthDay(dateTime);
    } else {
      return formatDate(dateTime);
    }
  }

  /// 解析日期字符串
  static DateTime? parse(String dateString, {String? format}) {
    try {
      final formatter = DateFormat(format ?? _fullFormat);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// 获取时间戳（秒）
  static int toTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// 从时间戳创建DateTime
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// 格式化日期时间为 "yyyy-MM-dd HH:mm"（兼容内联 _formatDateTime 格式）
  static String formatYMDHM(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 获取两个日期之间的天数
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// 获取日期范围的描述
  static String dateRangeDescription(DateTime start, DateTime end) {
    final days = daysBetween(start, end);
    if (days == 0) {
      return '今天';
    } else if (days == 1) {
      return '明天';
    } else if (days == -1) {
      return '昨天';
    } else if (days > 0 && days <= 7) {
      return '$days天后';
    } else if (days < 0 && days >= -7) {
      return '${-days}天前';
    } else {
      return '${formatDate(start)} - ${formatDate(end)}';
    }
  }
}
