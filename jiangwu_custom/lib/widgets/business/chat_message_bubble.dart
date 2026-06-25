import 'package:flutter/material.dart';
import '../../app/constants.dart';
import '../../models/message.dart';
import 'package:intl/intl.dart';

/// 聊天消息气泡组件
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String? otherAvatar;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.otherAvatar,
  });

  @override
  Widget build(BuildContext context) {
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
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.divider,
                backgroundImage: otherAvatar != null
                    ? NetworkImage(otherAvatar!)
                    : null,
                child: otherAvatar == null
                    ? const Icon(Icons.person, size: 20, color: AppColors.textHint)
                    : null,
              ),
              const SizedBox(width: AppSizes.spacingSmall),
            ],
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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? AppColors.white.withValues(alpha: 0.7)
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
    switch (status) {
      case 0:
        return SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            color: AppColors.white.withValues(alpha: 0.7),
          ),
        );
      case 1:
        return Icon(
          Icons.check,
          size: 12,
          color: AppColors.white.withValues(alpha: 0.7),
        );
      case 2:
        return Icon(
          Icons.done_all,
          size: 12,
          color: AppColors.white.withValues(alpha: 0.7),
        );
      default:
        return const SizedBox.shrink();
    }
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
