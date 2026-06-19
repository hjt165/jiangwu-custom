import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

/// 用户状态管理
/// 使用Riverpod实现

class UserNotifier extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user?.isLoggedIn ?? false;

  /// 登录
  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(
        phone: phone,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 注册
  Future<bool> register({
    required String phone,
    required String code,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        phone: phone,
        code: code,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 发送验证码
  Future<bool> sendVerificationCode(String phone) async {
    try {
      return await _authService.sendVerificationCode(phone);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 重置密码
  Future<bool> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        phone: phone,
        code: code,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  /// 更新用户资料
  Future<bool> updateProfile({
    String? nickname,
    String? avatar,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/user/update',
        data: {
          if (nickname != null) 'nickname': nickname,
          if (avatar != null) 'avatar': avatar,
        },
      );

      if (_user != null) {
        _user = User.fromJson(response);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 从本地存储恢复会话
  Future<bool> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.restoreSession();
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Riverpod Provider
final userProvider = ChangeNotifierProvider<UserNotifier>((ref) {
  return UserNotifier();
});