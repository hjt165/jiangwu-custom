/// 验证工具类
/// 提供表单验证功能

class Validators {
  Validators._();

  /// 手机号验证（中国大陆）
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    final phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegExp.hasMatch(value)) {
      return '请输入正确的手机号';
    }
    return null;
  }

  /// 密码验证（6-20位，至少包含字母和数字）
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少6位';
    }
    if (value.length > 20) {
      return '密码最多20位';
    }
    final passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{6,20}$');
    if (!passwordRegExp.hasMatch(value)) {
      return '密码需包含字母和数字';
    }
    return null;
  }

  /// 确认密码验证
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != password) {
      return '两次输入密码不一致';
    }
    return null;
  }

  /// 验证码验证（6位数字）
  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }
    if (value.length != 6) {
      return '验证码为6位数字';
    }
    final codeRegExp = RegExp(r'^\d{6}$');
    if (!codeRegExp.hasMatch(value)) {
      return '验证码格式错误';
    }
    return null;
  }

  /// 昵称验证（2-20个字符）
  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入昵称';
    }
    if (value.length < 2) {
      return '昵称至少2个字符';
    }
    if (value.length > 20) {
      return '昵称最多20个字符';
    }
    return null;
  }

  /// 姓名验证（2-20个字符）
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入姓名';
    }
    if (value.length < 2) {
      return '姓名至少2个字符';
    }
    if (value.length > 20) {
      return '姓名最多20个字符';
    }
    return null;
  }

  /// 邮箱验证
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return '请输入正确的邮箱';
    }
    return null;
  }

  /// 身份证验证（18位）
  static String? validateIdCard(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入身份证号';
    }
    final idCardRegExp = RegExp(
      r'^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$',
    );
    if (!idCardRegExp.hasMatch(value)) {
      return '请输入正确的身份证号';
    }
    return null;
  }

  /// 非空验证
  static String? validateRequired(String? value, {String fieldName = '此字段'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  /// 最小长度验证
  static String? validateMinLength(String? value, int minLength, {String fieldName = '内容'}) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    if (value.length < minLength) {
      return '$fieldName至少$minLength个字符';
    }
    return null;
  }

  /// 最大长度验证
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = '内容'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName最多$maxLength个字符';
    }
    return null;
  }

  /// 金额验证（正数，最多两位小数）
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入金额';
    }
    final amountRegExp = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!amountRegExp.hasMatch(value)) {
      return '请输入正确的金额';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return '金额必须大于0';
    }
    return null;
  }

  /// URL验证
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入URL';
    }
    final urlRegExp = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegExp.hasMatch(value)) {
      return '请输入正确的URL';
    }
    return null;
  }

  /// 价格范围验证
  static String? validatePriceRange(String? minPrice, String? maxPrice) {
    final min = double.tryParse(minPrice ?? '');
    final max = double.tryParse(maxPrice ?? '');

    if (min != null && max != null && min > max) {
      return '最低价格不能大于最高价格';
    }
    return null;
  }

  /// 组合验证（返回第一个错误）
  static String? validate(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
