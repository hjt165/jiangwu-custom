import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
import '../../providers/chat_provider.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

/// 聊天页面
/// 用户与手作人沟通定制细节
class ChatScreen extends ConsumerStatefulWidget {
  final int conversationId;
  final String otherName;
  final String? otherAvatar;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherName,
    this.otherAvatar,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 选择会话并加载消息
    Future.microtask(() {
      ref.read(chatProvider.notifier).selectConversation(widget.conversationId);
    });

    // 监听新消息，自动滚动到底部
    ref.listenManual(chatProvider, (prev, next) {
      if (next.currentMessages.length > (prev?.currentMessages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    // 监听滚动，上拉加载更多消息
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 当滚动到顶部时加载更多消息
    if (_scrollController.position.pixels <= 0) {
      ref.read(chatProvider.notifier).loadMoreMessages();
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(content);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // 显示加载中
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在发送图片...')),
        );
      }

      // 上传图片
      final storageService = ref.read(storageServiceProvider);
      final imageUrl = await storageService.uploadImage(image.path);

      if (imageUrl != null) {
        // 发送图片消息
        ref.read(chatProvider.notifier).sendMessage(
          imageUrl,
          messageType: 'image',
        );
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送图片失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final user = ref.watch(authServiceProvider).currentUser;
    final currentUserId = user?.id ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (!chatState.isConnected)
              const Text(
                '连接中...',
                style: TextStyle(fontSize: 12, color: AppColors.warning),
              ),
          ],
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 连接状态提示
          if (!chatState.isConnected)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.warning.withOpacity(0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('正在连接...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),

          // 消息列表
          Expanded(
            child: chatState.isLoadingMessages
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : chatState.currentMessages.isEmpty
                    ? const Center(
                        child: Text(
                          '开始与手作人沟通吧',
                          style: TextStyle(color: AppColors.textHint),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        itemCount: chatState.currentMessages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.currentMessages[index];
                          final isMe = message.senderId == currentUserId;
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),

          // 错误提示
          if (chatState.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.error.withOpacity(0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => ref.read(chatProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),

          // 输入区域
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.spacingMedium),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              // 对方头像
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.divider,
                backgroundImage: widget.otherAvatar != null
                    ? NetworkImage(widget.otherAvatar!)
                    : null,
                child: widget.otherAvatar == null
                    ? const Icon(Icons.person, size: 20, color: AppColors.textHint)
                    : null,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
            ],
            // 消息内容
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppSizes.radiusMedium),
                    topRight: const Radius.circular(AppSizes.radiusMedium),
                    bottomLeft: Radius.circular(isMe ? AppSizes.radiusMedium : 4),
                    bottomRight: Radius.circular(isMe ? 4 : AppSizes.radiusMedium),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 消息类型处理
                    if (message.messageType == 'image')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.content,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 150,
                            height: 150,
                            color: AppColors.divider,
                            child: const Icon(Icons.image, color: AppColors.textHint),
                          ),
                        ),
                      )
                    else
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: isMe ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    // 时间和状态
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? AppColors.white.withOpacity(0.7)
                                : AppColors.textHint,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _buildMessageStatus(message.status),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: AppSizes.spacingSmall),
              // 用户头像
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 20, color: AppColors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatus(int status) {
    // status: 0-发送中 1-已发送 2-已读
    switch (status) {
      case 0:
        return SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            color: AppColors.white.withOpacity(0.7),
          ),
        );
      case 1:
        return Icon(
          Icons.check,
          size: 12,
          color: AppColors.white.withOpacity(0.7),
        );
      case 2:
        return Icon(
          Icons.done_all,
          size: 12,
          color: AppColors.white.withOpacity(0.7),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingMedium,
        right: AppSizes.paddingMedium,
        top: AppSizes.paddingSmall,
        bottom: MediaQuery.of(context).padding.bottom + AppSizes.paddingSmall,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 图片按钮
          IconButton(
            icon: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
            onPressed: _pickAndSendImage,
          ),
          // 输入框
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入消息...',
                hintStyle: const TextStyle(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                  vertical: AppSizes.paddingSmall,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          // 发送按钮
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${DateFormat('HH:mm').format(time)}';
    } else if (now.difference(time).inDays < 7) {
      final weekDay = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][time.weekday - 1];
      return '$weekDay ${DateFormat('HH:mm').format(time)}';
    } else {
      return DateFormat('MM/dd HH:mm').format(time);
    }
  }
}