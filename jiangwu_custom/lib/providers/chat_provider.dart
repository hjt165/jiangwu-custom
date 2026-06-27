import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

/// 聊天状态
class ChatState {
  final List<Conversation> conversations;
  final List<ChatMessage> currentMessages;
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final bool isConnected;
  final int? currentConversationId;
  final String? error;

  ChatState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.isConnected = false,
    this.currentConversationId,
    this.error,
  });

  ChatState copyWith({
    List<Conversation>? conversations,
    List<ChatMessage>? currentMessages,
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    bool? isConnected,
    int? currentConversationId,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoadingConversations: isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isConnected: isConnected ?? this.isConnected,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// 聊天Provider
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final AuthService _authService;

  ChatNotifier(this._chatService, this._authService) : super(ChatState()) {
    _init();
  }

  void _init() {
    // 监听连接状态
    _chatService.connectionStream.listen((connected) {
      state = state.copyWith(isConnected: connected);
    });

    // 监听新消息
    _chatService.messageStream.listen((message) {
      _handleNewMessage(message);
    });
  }

  /// 连接WebSocket
  Future<void> connect() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _chatService.connect(int.parse(user.id));
    }
  }

  /// 断开连接
  void disconnect() {
    _chatService.disconnect();
  }

  /// 加载会话列表
  Future<void> loadConversations() async {
    state = state.copyWith(isLoadingConversations: true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final conversations = await _chatService.getConversations();
        state = state.copyWith(
          conversations: conversations,
          isLoadingConversations: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoadingConversations: false,
          error: '请先登录',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingConversations: false,
        error: '加载会话列表失败: $e',
      );
    }
  }

  /// 选择会话
  Future<void> selectConversation(int conversationId) async {
    state = state.copyWith(
      currentConversationId: conversationId,
      isLoadingMessages: true,
      currentMessages: [],
    );

    try {
      final messages = await _chatService.getMessages(conversationId);
      final user = _authService.currentUser;

      // 标记消息是否为当前用户发送
      final updatedMessages = messages.map((msg) {
        return msg;
      }).toList();

      state = state.copyWith(
        currentMessages: updatedMessages,
        isLoadingMessages: false,
        clearError: true,
      );

      // 标记已读
      if (user != null) {
        _chatService.markAsRead(conversationId);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMessages: false,
        error: '加载消息失败: $e',
      );
    }
  }

  /// 发送消息
  Future<void> sendMessage(String content, {String messageType = 'text'}) async {
    final conversationId = state.currentConversationId;
    if (conversationId == null) return;

    try {
      _chatService.sendMessage(conversationId, content, messageType: messageType);
    } catch (e) {
      // 如果WebSocket发送失败，使用REST API
      final user = _authService.currentUser;
      if (user != null) {
        try {
          await _chatService.sendMessageRest(
            conversationId,
            int.parse(user.id),
            content,
            messageType: messageType,
          );
          // 重新加载消息
          await selectConversation(conversationId);
        } catch (restError) {
          state = state.copyWith(error: '发送消息失败: $restError');
        }
      }
    }
  }

  /// 加载更多消息（上拉加载）
  Future<void> loadMoreMessages() async {
    final conversationId = state.currentConversationId;
    if (conversationId == null || state.currentMessages.isEmpty) return;

    try {
      final oldestMessage = state.currentMessages.first;
      final moreMessages = await _chatService.getHistoryMessages(
        conversationId,
        oldestMessage.createdAt.toIso8601String(),
      );

      if (moreMessages.isNotEmpty) {
        state = state.copyWith(
          currentMessages: [...moreMessages, ...state.currentMessages],
        );
      }
    } catch (e) {
      state = state.copyWith(error: '加载更多消息失败: $e');
    }
  }

  /// 处理新消息
  void _handleNewMessage(ChatMessage message) {
    final user = _authService.currentUser;
    if (user == null) return;

    // 如果是当前会话的消息，添加到列表
    if (message.conversationId == state.currentConversationId) {
      state = state.copyWith(
        currentMessages: [...state.currentMessages, message],
      );

      // 标记已读
      _chatService.markAsRead(message.conversationId);
    }

    // 更新会话列表中的最后消息
    _updateConversationLastMessage(message);
  }

  /// 更新会话最后消息
  void _updateConversationLastMessage(ChatMessage message) {
    final conversations = List<Conversation>.from(state.conversations);
    final index = conversations.indexWhere((c) => c.id == message.conversationId);

    if (index != -1) {
      // 这里简化处理，实际应该更新会话的lastMessage和lastMessageAt
      // 重新加载会话列表更准确
      loadConversations();
    }
  }

  /// 创建新会话
  Future<Conversation> createConversation(int artisanId, {int? orderId}) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('用户未登录');

    final conversation = await _chatService.getOrCreateConversation(
      int.parse(user.id),
      artisanId,
      orderId: orderId,
    );

    // 刷新会话列表
    await loadConversations();

    return conversation;
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// 聊天Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return ChatNotifier(chatService, authService);
});