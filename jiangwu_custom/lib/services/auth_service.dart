import '../models/user.dart';
import 'api_service.dart';

/// 认证服务
/// 处理登录、注册、Token管理等认证相关逻辑

class AuthService {
  // 单例模式
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // 当前用户
  User? _currentUser;

  /// 获取当前用户
  User? get currentUser => _currentUser;

  /// 是否已登录
  bool get isLoggedIn => _currentUser?.isLoggedIn ?? false;

  /// 登录
  Future<User> login({
    required String phone,
    required String password,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/user/login',
      data: {
        'phone': phone,
        'password': password,
      },
    );

    final user = User.fromJson(response);

    // 持久化 Token
    if (user.token != null) {
      await _apiService.saveToken(user.token!);
    }

    _currentUser = user;
    return user;
  }

  /// 注册
  Future<User> register({
    required String phone,
    required String code,
    required String password,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/user/register',
      data: {
        'phone': phone,
        'code': code,
        'password': password,
      },
    );

    final user = User.fromJson(response);

    // 持久化 Token
    if (user.token != null) {
      await _apiService.saveToken(user.token!);
    }

    _currentUser = user;
    return user;
  }

  /// 发送验证码
  Future<bool> sendVerificationCode(String phone) async {
    await _apiService.post<void>(
      '/user/send-code',
      data: {'phone': phone},
    );
    return true;
  }

  /// 获取当前用户信息（从服务器刷新）
  Future<User?> fetchCurrentUser() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/user/info',
      );
      final user = User.fromJson(response);
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _apiService.clearToken();
    _currentUser = null;
  }

  /// 获取Token
  String? get token => _currentUser?.token;

  /// 从本地存储恢复用户（启动时调用）
  Future<User?> restoreSession() async {
    final token = await _apiService.getToken();
    if (token == null || token.isEmpty) return null;

    // Token存在，尝试获取用户信息
    return await fetchCurrentUser();
  }
}