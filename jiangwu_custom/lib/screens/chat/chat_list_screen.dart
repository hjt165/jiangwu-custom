import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/constants.dart';
import '../../providers/chat_provider.dart';
import '../../services/auth_service.dart';
import 'chat_screen.dart';

/// 聊天列表页
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // 加载会话列表
    Future.microtask(() {
      ref.read(chatProvider.notifier).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final user = ref.watch(authServiceProvider).currentUser;
    final isArtisan = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('我的消息', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: chatState.isLoadingConversations
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : chatState.conversations.isEmpty
              ? _buildEmptyWidget()
              : _buildConversationList(chatState, isArtisan),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.textHint),
          SizedBox(height: AppSizes.spacingMedium),
          Text('暂无聊天记录', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          SizedBox(height: AppSizes.spacingSmall),
          Text('浏览手作人作品时，可以点击联系发起聊天', style: TextStyle(color: AppColors.textHint, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildConversationList(ChatState chatState, bool isArtisan) {
    return RefreshIndicator(
      onRefresh: () => ref.read(chatProvider.notifier).loadConversations(),
      child: ListView.separated(
        itemCount: chatState.conversations.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) {
          final conversation = chatState.conversations[index];
          return _buildConversationItem(conversation, isArtisan);
        },
      ),
    );
  }

  Widget _buildConversationItem(conversation, bool isArtisan) {
    final otherName = conversation.getOtherName(isArtisan);
    final otherAvatar = conversation.getOtherAvatar(isArtisan);
    final unreadCount = conversation.getUnreadCount(isArtisan);
    final lastMessage = conversation.lastMessage ?? '暂无消息';
    final lastMessageAt = conversation.lastMessageAt;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha:0.1),
            backgroundImage: otherAvatar != null ? NetworkImage(otherAvatar) : null,
            child: otherAvatar == null
                ? Text(
                    otherName.isNotEmpty ? otherName[0] : '?',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: TextStyle(color: AppColors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessageAt != null)
            Text(
              _formatTime(lastMessageAt),
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text(
          lastMessage,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversation.id,
              otherName: otherName,
              otherAvatar: otherAvatar,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      return '昨天';
    } else if (now.difference(time).inDays < 7) {
      return ['周一', '周二', '周三', '周四', '周五', '周六', '周日'][time.weekday - 1];
    } else {
      return DateFormat('MM/dd').format(time);
    }
  }
}