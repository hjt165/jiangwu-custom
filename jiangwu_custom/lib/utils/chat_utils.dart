import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/order.dart';
import '../screens/chat/chat_screen.dart';

/// 聊天工具类
class ChatUtils {
  ChatUtils._();

  /// 创建或获取与手作人的会话并跳转到聊天页面
  static Future<void> contactArtisan(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null || order.artisanId == null) return;

    try {
      final chatService = ref.read(chatServiceProvider);
      final conversation = await chatService.getOrCreateConversation(
        int.parse(user.id),
        int.parse(order.artisanId!),
        orderId: int.tryParse(order.id),
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation.id,
              otherName: order.artisan?.name ?? '手作人',
              otherAvatar: order.artisan?.avatar,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建会话失败: $e')),
        );
      }
    }
  }
}
