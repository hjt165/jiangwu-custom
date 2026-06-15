import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'api_service.dart';

/// 极光推送服务
/// 封装jpush_flutter，实现推送注册/监听/别名管理

class PushService {
  // 单例模式
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  final ApiService _apiService = ApiService();
  final JPush _jPush = JPush();

  // 推送消息流
  StreamController<PushNotification>? _notificationController;
  Stream<PushNotification>? _notificationStream;

  // 推送ID
  String? _registrationId;
  bool _initialized = false;

  /// 初始化极光推送
  Future<void> init({
    Function(PushNotification)? onNotification,
  }) async {
    if (_initialized) return;

    try {
      // 初始化推送SDK
      // 请在极光开发者平台申请AppKey并替换
      // https://www.jiguang.cn/dev/#/app/list
      await _jPush.setup(
        appKey: const String.fromEnvironment('JPUSH_APP_KEY', defaultValue: 'your-app-key'),
        channel: 'developer-default',
        production: false,
        debug: true,
      );

      // 监听推送消息
      _jPush.addEventHandler(
        onReceiveNotification: (Map<String, dynamic> message) async {
          print('收到推送消息: $message');
          _handleNotification(message, isClicked: false);
        },
        onOpenNotification: (Map<String, dynamic> message) async {
          print('点击推送消息: $message');
          _handleNotification(message, isClicked: true);
        },
        onReceiveMessage: (Map<String, dynamic> message) async {
          print('收到应用内消息: $message');
        },
        onReceiveOfflineMessage: (Map<String, dynamic> message) async {
          print('收到离线消息: $message');
        },
      );

      // 获取推送ID
      _registrationId = await _jPush.getRegistrationID();
      print('极光推送ID: $_registrationId');

      // 注册推送ID到后端
      if (_registrationId != null && _registrationId!.isNotEmpty) {
        await _registerToServer(_registrationId!);
      }

      _initialized = true;
    } catch (e) {
      print('极光推送初始化失败: $e');
    }
  }

  /// 设置推送别名（用户ID）
  Future<void> setAlias(String userId) async {
    try {
      await _jPush.setAlias(userId);
      print('设置推送别名: $userId');
    } catch (e) {
      print('设置推送别名失败: $e');
    }
  }

  /// 清除推送别名
  Future<void> clearAlias() async {
    try {
      await _jPush.clearAlias();
      print('清除推送别名');
    } catch (e) {
      print('清除推送别名失败: $e');
    }
  }

  /// 设置标签
  Future<void> setTags(List<String> tags) async {
    try {
      await _jPush.setTags(tags);
      print('设置推送标签: $tags');
    } catch (e) {
      print('设置推送标签失败: $e');
    }
  }

  /// 清除标签
  Future<void> clearTags() async {
    try {
      await _jPush.cleanTags();
      print('清除推送标签');
    } catch (e) {
      print('清除推送标签失败: $e');
    }
  }

  /// 申请推送权限
  Future<bool> requestPermission() async {
    try {
      final result = await _jPush.applyPushAuthority(
        const NotificationSettingsIOS(
          sound: true,
          alert: true,
          badge: true,
        ),
      );
      return result ?? false;
    } catch (e) {
      print('申请推送权限失败: $e');
      return false;
    }
  }

  /// 获取推送ID
  String? get registrationId => _registrationId;

  /// 注册推送ID到后端
  Future<void> _registerToServer(String registrationId) async {
    try {
      await _apiService.post<void>(
        '/push/register',
        data: {
          'registrationId': registrationId,
          'platform': _getPlatform(),
        },
      );
      print('推送ID注册成功');
    } catch (e) {
      print('推送ID注册失败: $e');
    }
  }

  /// 处理推送消息
  void _handleNotification(Map<String, dynamic> message, {required bool isClicked}) {
    final notification = PushNotification(
      title: message['title'] ?? '',
      content: message['content'] ?? '',
      extras: message['extras'] ?? {},
      isClicked: isClicked,
    );

    _notificationController?.add(notification);
  }

  /// 获取推送消息流
  Stream<PushNotification> get onNotification {
    _notificationController ??= StreamController<PushNotification>.broadcast();
    _notificationStream ??= _notificationController!.stream;
    return _notificationStream!;
  }

  /// 获取平台类型
  String _getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// 释放资源
  void dispose() {
    _notificationController?.close();
  }
}

/// 推送通知模型
class PushNotification {
  final String title;
  final String content;
  final Map<String, dynamic> extras;
  final bool isClicked;

  PushNotification({
    required this.title,
    required this.content,
    this.extras = const {},
    this.isClicked = false,
  });

  /// 获取订单ID
  String? get orderId => extras['orderId']?.toString();

  /// 获取通知类型
  String? get type => extras['type']?.toString();

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'extras': extras,
      'isClicked': isClicked,
    };
  }

  /// 从JSON创建
  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      extras: json['extras'] ?? {},
      isClicked: json['isClicked'] ?? false,
    );
  }
}
