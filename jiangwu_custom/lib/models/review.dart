/// 评价模型
/// 包含评分、评价内容、图片

/// 评价模型
class Review {
  final String id;
  final String orderId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String artisanId;
  final String artisanName;
  final double rating;
  final String content;
  final List<String> images;
  final List<String> tags;
  final String? reply;
  final String? replyAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.artisanId,
    required this.artisanName,
    this.rating = 5,
    this.content = '',
    this.images = const [],
    this.tags = const [],
    this.reply,
    this.replyAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      artisanId: json['artisanId'] ?? '',
      artisanName: json['artisanName'] ?? '',
      rating: (json['rating'] ?? 5).toDouble(),
      content: json['content'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      reply: json['reply'],
      replyAt: json['replyAt'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'artisanId': artisanId,
      'artisanName': artisanName,
      'rating': rating,
      'content': content,
      'images': images,
      'tags': tags,
      'reply': reply,
      'replyAt': replyAt,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? artisanId,
    String? artisanName,
    double? rating,
    String? content,
    List<String>? images,
    List<String>? tags,
    String? reply,
    String? replyAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      artisanId: artisanId ?? this.artisanId,
      artisanName: artisanName ?? this.artisanName,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      reply: reply ?? this.reply,
      replyAt: replyAt ?? this.replyAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否有图片
  bool get hasImages => images.isNotEmpty;

  /// 是否有回复
  bool get hasReply => reply != null && reply!.isNotEmpty;

  /// 是否好评（4星及以上）
  bool get isPositive => rating >= 4;

  /// 获取评分文字
  String get ratingText {
    if (rating >= 4.5) return '非常满意';
    if (rating >= 4.0) return '满意';
    if (rating >= 3.0) return '一般';
    if (rating >= 2.0) return '不满意';
    return '非常不满意';
  }
}

/// 评价标签
class ReviewTags {
  ReviewTags._();

  static const List<String> positive = [
    '做工精细',
    '材质优良',
    '发货快',
    '包装精美',
    '物超所值',
    '手艺精湛',
    '耐心细致',
    '沟通顺畅',
    '按时交付',
    '推荐购买',
  ];

  static const List<String> negative = [
    '做工粗糙',
    '材质一般',
    '发货慢',
    '包装简陋',
    '与描述不符',
    '延期交付',
    '沟通困难',
    '态度不好',
  ];

  /// 获取所有标签
  static List<String> get all => [...positive, ...negative];
}
