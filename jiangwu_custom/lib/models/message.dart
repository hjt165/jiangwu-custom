/// 消息数据模型
class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final String messageType;
  final int status;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.status = 0,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      conversationId: json['conversationId'] ?? 0,
      senderId: json['senderId'] ?? 0,
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      status: json['status'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'messageType': messageType,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isMe => false; // 将在Provider中根据当前用户ID设置
}