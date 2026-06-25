import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/constants.dart';
import '../../providers/chat_provider.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/business/chat_message_bubble.dart';
import '../../widgets/business/chat_input_bar.dart';

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
    Future.microtask(() {
      ref.read(chatProvider.notifier).selectConversation(widget.conversationId);
    });

    ref.listenManual(chatProvider, (prev, next) {
      if (next.currentMessages.length > (prev?.currentMessages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(chatProvider.notifier).loadMoreMessages();
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在发送图片...')),
        );
      }

      final storageService = ref.read(storageServiceProvider);
      final imageUrl = await storageService.uploadImage(image.path);

      if (imageUrl != null) {
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
            onPressed: () => _showChatMenu(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!chatState.isConnected)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.warning.withValues(alpha: 0.1),
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
                          return ChatMessageBubble(
                            message: message,
                            isMe: isMe,
                            otherAvatar: widget.otherAvatar,
                          );
                        },
                      ),
          ),

          if (chatState.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: const TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => ref.read(chatProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),

          ChatInputBar(
            controller: _messageController,
            onSend: _sendMessage,
            onImagePick: _pickAndSendImage,
          ),
        ],
      ),
    );
  }

  void _showChatMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('清空聊天记录'),
              onTap: () {
                Navigator.pop(context);
                _confirmClearHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('拉黑用户'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已拉黑该用户')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('举报'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('举报已提交')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定要清空所有聊天记录吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('聊天记录已清空')),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
