/// 会话数据模型
class Conversation {
  final int id;
  final int userId;
  final int artisanId;
  final int? orderId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int userUnread;
  final int artisanUnread;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 额外字段（从关联查询获取）
  final String? userName;
  final String? userAvatar;
  final String? artisanName;
  final String? artisanAvatar;

  Conversation({
    required this.id,
    required this.userId,
    required this.artisanId,
    this.orderId,
    this.lastMessage,
    this.lastMessageAt,
    this.userUnread = 0,
    this.artisanUnread = 0,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
    this.artisanName,
    this.artisanAvatar,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      artisanId: json['artisanId'] ?? 0,
      orderId: json['orderId'],
      lastMessage: json['lastMessage'],
      lastMessageAt: DateTime.tryParse(json['lastMessageAt'] ?? ''),
      userUnread: json['userUnread'] ?? 0,
      artisanUnread: json['artisanUnread'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      userName: json['userName'],
      userAvatar: json['userAvatar'],
      artisanName: json['artisanName'],
      artisanAvatar: json['artisanAvatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'artisanId': artisanId,
      'orderId': orderId,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'userUnread': userUnread,
      'artisanUnread': artisanUnread,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 获取对方名称（根据当前用户角色）
  String getOtherName(bool isCurrentUserArtisan) {
    return isCurrentUserArtisan ? (userName ?? '用户') : (artisanName ?? '手作人');
  }

  /// 获取对方头像
  String? getOtherAvatar(bool isCurrentUserArtisan) {
    return isCurrentUserArtisan ? userAvatar : artisanAvatar;
  }

  /// 获取当前用户未读数
  int getUnreadCount(bool isCurrentUserArtisan) {
    return isCurrentUserArtisan ? artisanUnread : userUnread;
  }
}