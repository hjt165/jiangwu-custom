/// 手作人模型
/// 包含手作人信息、评分、作品集、认证状态

import 'product.dart';

/// 手作人认证状态
enum ArtisanStatus {
  pending('待认证'),
  verified('已认证'),
  rejected('认证失败'),
  suspended('已封禁');

  final String label;
  const ArtisanStatus(this.label);

  static ArtisanStatus fromString(String value) {
    return ArtisanStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ArtisanStatus.pending,
    );
  }
}

/// 手作人模型
class Artisan {
  final String id;
  final String userId;
  final String name;
  final String? avatar;
  final String? description;
  final String? specialty;
  final List<String> categories;
  final ArtisanStatus status;
  final double rating;
  final int ratingCount;
  final int orderCount;
  final int followerCount;
  final int followingCount;
  final int workCount;
  final List<Product> works;
  final List<String> certifications;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Artisan({
    required this.id,
    required this.userId,
    required this.name,
    this.avatar,
    this.description,
    this.specialty,
    this.categories = const [],
    this.status = ArtisanStatus.pending,
    this.rating = 0,
    this.ratingCount = 0,
    this.orderCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.workCount = 0,
    this.works = const [],
    this.certifications = const [],
    this.verifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      description: json['description'],
      specialty: json['specialty'],
      categories: List<String>.from(json['categories'] ?? []),
      status: ArtisanStatus.fromString(json['status'] ?? ''),
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      orderCount: json['orderCount'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      workCount: json['workCount'] ?? 0,
      works: (json['works'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
      certifications: List<String>.from(json['certifications'] ?? []),
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'description': description,
      'specialty': specialty,
      'categories': categories,
      'status': status.name,
      'rating': rating,
      'ratingCount': ratingCount,
      'orderCount': orderCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'workCount': workCount,
      'works': works.map((e) => e.toJson()).toList(),
      'certifications': certifications,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Artisan copyWith({
    String? id,
    String? userId,
    String? name,
    String? avatar,
    String? description,
    String? specialty,
    List<String>? categories,
    ArtisanStatus? status,
    double? rating,
    int? ratingCount,
    int? orderCount,
    int? followerCount,
    int? followingCount,
    int? workCount,
    List<Product>? works,
    List<String>? certifications,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Artisan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      specialty: specialty ?? this.specialty,
      categories: categories ?? this.categories,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      orderCount: orderCount ?? this.orderCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      workCount: workCount ?? this.workCount,
      works: works ?? this.works,
      certifications: certifications ?? this.certifications,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否已认证
  bool get isVerified => status == ArtisanStatus.verified;

  /// 是否有作品
  bool get hasWorks => works.isNotEmpty;

  /// 获取评级文字
  String get ratingText {
    if (rating >= 4.5) return '金牌手作人';
    if (rating >= 4.0) return '优秀手作人';
    if (rating >= 3.5) return '资深手作人';
    return '新手手作人';
  }

  /// 获取认证标签
  String get certificationBadge {
    if (certifications.isEmpty) return '';
    return certifications.first;
  }
}
