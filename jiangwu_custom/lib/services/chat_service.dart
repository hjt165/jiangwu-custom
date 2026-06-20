import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../app/constants.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// 聊天服务
class ChatService {
  final ApiService _apiService;
  final AuthService _authService;
  WebSocketChannel? _channel;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  int? _currentUserId;

  ChatService(this._apiService, this._authService);

  /// 消息流
  Stream<ChatMessage> get messageStream => _messageController.stream;

  /// 连接状态流
  Stream<bool> get connectionStream => _connectionController.stream;

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 连接WebSocket
  Future<void> connect(int userId) async {
    _currentUserId = userId;
    try {
      final token = await _apiService.getToken();
      final wsUrl = ApiConstants.baseUrl.replaceFirst('http', 'ws') + '/ws/chat?token=$token';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (data) {
          final message = jsonDecode(data);
          _handleMessage(message);
        },
        onDone: () {
          _isConnected = false;
          _connectionController.add(false);
          _startReconnect();
        },
        onError: (error) {
          developer.log('WebSocket error: $error');
          _isConnected = false;
          _connectionController.add(false);
          _startReconnect();
        },
      );

      _isConnected = true;
      _connectionController.add(true);
      _startHeartbeat();
    } catch (e) {
      developer.log('WebSocket connection failed: $e');
      _startReconnect();
    }
  }

  /// 断开连接
  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _connectionController.add(false);
  }

  /// 发送消息
  void sendMessage(int conversationId, String content, {String messageType = 'text'}) {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket未连接');
    }

    final message = {
      'type': 'chat',
      'conversationId': conversationId,
      'content': content,
      'messageType': messageType,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// 标记已读
  void markAsRead(int conversationId) {
    if (!_isConnected || _channel == null) return;

    final message = {
      'type': 'read',
      'conversationId': conversationId,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// 处理收到的消息
  void _handleMessage(Map<String, dynamic> message) {
    final type = message['type'];

    switch (type) {
      case 'chat':
        final chatMessage = ChatMessage.fromJson(message);
        _messageController.add(chatMessage);
        break;
      case 'chat_echo':
        // 发送成功回显，可选处理
        break;
      case 'read':
        // 已读通知，可选处理
        break;
      case 'pong':
        // 心跳响应
        break;
      case 'error':
        developer.log('Server error: ${message['message']}');
        break;
    }
  }

  /// 启动心跳
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_isConnected && _channel != null) {
        _channel!.sink.add(jsonEncode({'type': 'ping'}));
      }
    });
  }

  /// 启动重连
  void _startReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (_currentUserId != null && !_isConnected) {
        connect(_currentUserId!);
      }
    });
  }

  // ============ REST API 方法 ============

  /// 获取或创建会话
  Future<Conversation> getOrCreateConversation(int userId, int artisanId, {int? orderId}) async {
    final response = await _apiService.get(
      '/chat/conversation',
      queryParameters: {
        'userId': userId,
        'artisanId': artisanId,
        if (orderId != null) 'orderId': orderId,
      },
    );
    return Conversation.fromJson(response.data['data']);
  }

  /// 获取用户会话列表
  Future<List<Conversation>> getConversations(int userId) async {
    final response = await _apiService.get('/chat/conversations/$userId');
    final list = response.data['data'] as List;
    return list.map((e) => Conversation.fromJson(e)).toList();
  }

  /// 获取会话消息列表
  Future<List<ChatMessage>> getMessages(int conversationId, {int limit = 50}) async {
    final response = await _apiService.get(
      '/chat/messages/$conversationId',
      queryParameters: {'limit': limit},
    );
    final list = response.data['data'] as List;
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  /// 获取历史消息（分页）
  Future<List<ChatMessage>> getHistoryMessages(
    int conversationId,
    String before, {
    int limit = 50,
  }) async {
    final response = await _apiService.get(
      '/chat/messages/$conversationId/history',
      queryParameters: {'before': before, 'limit': limit},
    );
    final list = response.data['data'] as List;
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  /// REST方式发送消息（备选方案）
  Future<ChatMessage> sendMessageRest(
    int conversationId,
    int senderId,
    String content, {
    String messageType = 'text',
  }) async {
    final response = await _apiService.post('/chat/send', data: {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'messageType': messageType,
    });
    return ChatMessage.fromJson(response.data['data']);
  }

  /// 获取未读消息数
  Future<int> getUnreadCount(int userId, {String role = 'user'}) async {
    final response = await _apiService.get(
      '/chat/unread/$userId',
      queryParameters: {'role': role},
    );
    return response.data['data']['unreadCount'] ?? 0;
  }

  /// 标记已读（REST方式）
  Future<void> markAsReadRest(int conversationId, int userId) async {
    await _apiService.post('/chat/read/$conversationId', queryParameters: {'userId': userId});
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}

/// 聊天服务Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return ChatService(apiService, authService);
});