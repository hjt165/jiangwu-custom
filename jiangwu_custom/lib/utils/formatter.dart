/// 格式化工具类
/// 提供金额、手机号、身份证等格式化功能

class Formatter {
  Formatter._();

  /// 格式化金额（保留两位小数）
  static String formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    final double value = amount is double ? amount : double.tryParse(amount.toString()) ?? 0;
    return value.toStringAsFixed(2);
  }

  /// 格式化金额（带人民币符号）
  static String formatAmountWithSymbol(dynamic amount) {
    return '¥${formatAmount(amount)}';
  }

  /// 格式化金额（带千分位）
  static String formatAmountWithCommas(dynamic amount) {
    if (amount == null) return '0.00';
    final double value = amount is double ? amount : double.tryParse(amount.toString()) ?? 0;
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decimalPart = parts[1];

    // 添加千分位
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return '${buffer.toString()}.$decimalPart';
  }

  /// 手机号脱敏（138****8888）
  static String maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return phone.replaceRange(3, phone.length - 4, '****');
  }

  /// 身份证脱敏（110***********1234）
  static String maskIdCard(String idCard) {
    if (idCard.length < 8) return idCard;
    return idCard.replaceRange(3, idCard.length - 4, '***********');
  }

  /// 姓名脱敏（张*）
  static String maskName(String name) {
    if (name.length <= 1) return name;
    return '${name[0]}*';
  }

  /// 银行卡脱敏（6222 **** **** 1234）
  static String maskBankCard(String cardNo) {
    if (cardNo.length < 8) return cardNo;
    final visible = cardNo.substring(0, 4) + cardNo.substring(cardNo.length - 4);
    final masked = cardNo.substring(4, cardNo.length - 4).replaceAll(RegExp(r'\d'), '*');
    return '$visible$masked';
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// 格式化数字（超过1万显示x.x万）
  static String formatNumber(int number) {
    if (number < 10000) {
      return number.toString();
    } else if (number < 100000000) {
      final wan = number / 10000;
      return '${wan.toStringAsFixed(wan.floor() == wan ? 0 : 1)}万';
    } else {
      final yi = number / 100000000;
      return '${yi.toStringAsFixed(yi.floor() == yi ? 0 : 1)}亿';
    }
  }

  /// 格式化时长（秒 -> "01:30"）
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 格式化时长（秒 -> "1分30秒"）
  static String formatDurationWithUnit(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes == 0) {
      return '$remainingSeconds秒';
    } else if (remainingSeconds == 0) {
      return '$minutes分钟';
    } else {
      return '$minutes分$remainingSeconds秒';
    }
  }

  /// 格式化手机号（加空格：138 8888 8888）
  static String formatPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)} ${phone.substring(3, 7)} ${phone.substring(7)}';
  }

  /// 格式化订单号（JW20260614 001）
  static String formatOrderNo(String orderNo) {
    if (orderNo.length < 12) return orderNo;
    return '${orderNo.substring(0, 10)} ${orderNo.substring(10)}';
  }
}
