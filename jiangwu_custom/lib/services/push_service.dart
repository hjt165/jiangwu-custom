import 'dart:async';
import 'dart:developer' as developer;

/// 极光推送服务 (Mock模式 - jpush_flutter暂未兼容)
/// 保持接口不变，后续恢复推送时替换

class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  StreamController<PushNotification>? _notificationController;
  Stream<PushNotification>? _notificationStream;

  String? _registrationId;
  bool _initialized = false;

  Future<void> init({
    Function(PushNotification)? onNotification,
  }) async {
    if (_initialized) return;
    developer.log('PushService: 推送服务已禁用(mock模式)');
    _initialized = true;
  }

  Future<void> setAlias(String userId) async {
    developer.log('PushService: setAlias($userId) - mock');
  }

  Future<void> clearAlias() async {
    developer.log('PushService: clearAlias - mock');
  }

  Future<void> setTags(List<String> tags) async {
    developer.log('PushService: setTags($tags) - mock');
  }

  Future<void> clearTags() async {
    developer.log('PushService: clearTags - mock');
  }

  Future<bool> requestPermission() async {
    return true;
  }

  String? get registrationId => _registrationId;

  Stream<PushNotification> get onNotification {
    _notificationController ??= StreamController<PushNotification>.broadcast();
    _notificationStream ??= _notificationController!.stream;
    return _notificationStream!;
  }

  void dispose() {
    _notificationController?.close();
  }
}

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

  String? get orderId => extras['orderId']?.toString();
  String? get type => extras['type']?.toString();

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'extras': extras,
      'isClicked': isClicked,
    };
  }

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      extras: json['extras'] ?? {},
      isClicked: json['isClicked'] ?? false,
    );
  }
}
