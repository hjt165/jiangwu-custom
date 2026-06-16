import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants.dart';

/// API服务
/// 封装Dio，统一处理请求/响应拦截

/// 全局导航回调，用于401时跳转登录页
typedef OnUnauthorized = void Function();

class ApiService {
  // 单例模式
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  late final Dio _dio;

  /// 401未授权回调（由main.dart设置）
  static OnUnauthorized? onUnauthorized;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _initInterceptors();
  }

  /// 初始化拦截器
  void _initInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      // 请求拦截器
      onRequest: (options, handler) async {
        // 添加Token
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        print('''
[API Request]
URI: 
Method: 
Headers: 
Data: 
''');

        handler.next(options);
      },

      // 响应拦截器
      onResponse: (response, handler) {
        print('''
[API Response]
URI: 
Status: 
Data: 
''');

        // 处理业务响应码
        if (response.data is Map) {
          final code = response.data['code'];
          if (code != null && code != 200 && code != 0) {
            final message = response.data['message'] ?? '请求失败';
            handler.reject(DioException(
              requestOptions: response.requestOptions,
              response: response,
              message: message,
            ));
            return;
          }

          // 提取 data 字段，使 fromJson 直接接收业务数据
          if (response.data.containsKey('data')) {
            response.data = response.data['data'];
          }
        }

        handler.next(response);
      },

      // 错误拦截器
      onError: (error, handler) {
        print('''
[API Error]
URI: 
Type: 
Message: 
''');

        // 处理401未授权
        if (error.response?.statusCode == 401) {
          clearToken();
          onUnauthorized?.call();
        }

        handler.next(error);
      },
    ));
  }

  // ==================== Token管理 ====================

  /// 获取Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(CacheKeys.token);
  }

  /// 保存Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(CacheKeys.token, token);
  }

  /// 清除Token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(CacheKeys.token);
  }

  /// 是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== 基础请求方法 ====================

  /// GET请求
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  /// POST请求
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  /// PUT请求
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  /// DELETE请求
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  /// 上传文件
  Future<T> upload<T>(
    String path, {
    required String filePath,
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (data != null) ...data,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  /// 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        deleteOnError: deleteOnError,
      );
    } on DioException {
      rethrow;
    }
  }

  /// 取消所有请求
  void cancelAllRequests() {
    _dio.close(force: true);
  }

  // ==================== 收藏 API ====================

  /// 收藏作品
  Future<void> addFavorite(String productId) async {
    await post('/favorite/$productId');
  }

  /// 取消收藏
  Future<void> removeFavorite(String productId) async {
    await delete('/favorite/$productId');
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(String productId) async {
    final result = await post<Map<String, dynamic>>(
      '/favorite/$productId/toggle',
      fromJson: (data) => Map<String, dynamic>.from(data),
    );
    return result['isFavorited'] ?? false;
  }

  /// 检查是否已收藏
  Future<bool> checkFavorite(String productId) async {
    final result = await get<Map<String, dynamic>>(
      '/favorite/check/$productId',
      fromJson: (data) => Map<String, dynamic>.from(data),
    );
    return result['isFavorited'] ?? false;
  }

  /// 获取收藏列表
  Future<List<dynamic>> getFavoriteList() async {
    return await get('/favorite/list');
  }

  // ==================== 浏览历史 API ====================

  /// 记录浏览
  Future<void> recordBrowseHistory(String productId) async {
    await post('/history/record', data: {'productId': int.parse(productId)});
  }

  /// 获取浏览历史列表
  Future<List<dynamic>> getHistoryList() async {
    return await get('/history/list');
  }

  /// 清空浏览历史
  Future<void> clearHistory() async {
    await delete('/history/clear');
  }
}

/// API服务 Riverpod Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});