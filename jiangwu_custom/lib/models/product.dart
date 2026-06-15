/// 作品模型
/// 包含作品信息、图片、工艺参数、价格

/// 作品分类枚举
enum ProductCategory {
  jewelry('首饰'),
  leather('皮具'),
  ceramic('陶瓷'),
  woodwork('木艺'),
  painting('绘画'),
  other('其他');

  final String label;
  const ProductCategory(this.label);

  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductCategory.other,
    );
  }
}

/// 工艺参数模型
class CraftParams {
  final String difficulty;
  final int estimatedDays;
  final double materialCost;
  final double laborCost;
  final String technique;
  final Map<String, dynamic>? extra;

  const CraftParams({
    this.difficulty = '中等',
    this.estimatedDays = 7,
    this.materialCost = 0,
    this.laborCost = 0,
    this.technique = '',
    this.extra,
  });

  factory CraftParams.fromJson(Map<String, dynamic> json) {
    return CraftParams(
      difficulty: json['difficulty'] ?? '中等',
      estimatedDays: json['estimatedDays'] ?? 7,
      materialCost: (json['materialCost'] ?? 0).toDouble(),
      laborCost: (json['laborCost'] ?? 0).toDouble(),
      technique: json['technique'] ?? '',
      extra: json['extra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'estimatedDays': estimatedDays,
      'materialCost': materialCost,
      'laborCost': laborCost,
      'technique': technique,
      'extra': extra,
    };
  }

  /// 总成本
  double get totalCost => materialCost + laborCost;

  CraftParams copyWith({
    String? difficulty,
    int? estimatedDays,
    double? materialCost,
    double? laborCost,
    String? technique,
    Map<String, dynamic>? extra,
  }) {
    return CraftParams(
      difficulty: difficulty ?? this.difficulty,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      materialCost: materialCost ?? this.materialCost,
      laborCost: laborCost ?? this.laborCost,
      technique: technique ?? this.technique,
      extra: extra ?? this.extra,
    );
  }
}

/// 作品模型
class Product {
  final String id;
  final String artisanId;
  final String title;
  final String description;
  final ProductCategory category;
  final List<String> images;
  final String? coverImage;
  final double price;
  final double? originalPrice;
  final CraftParams craftParams;
  final List<String> materials;
  final List<String> tags;
  final int viewCount;
  final int likeCount;
  final int orderCount;
  final double rating;
  final bool isFeatured;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.artisanId,
    required this.title,
    this.description = '',
    this.category = ProductCategory.other,
    this.images = const [],
    this.coverImage,
    this.price = 0,
    this.originalPrice,
    this.craftParams = const CraftParams(),
    this.materials = const [],
    this.tags = const [],
    this.viewCount = 0,
    this.likeCount = 0,
    this.orderCount = 0,
    this.rating = 0,
    this.isFeatured = false,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      artisanId: json['artisanId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: ProductCategory.fromString(json['category'] ?? ''),
      images: List<String>.from(json['images'] ?? []),
      coverImage: json['coverImage'],
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      craftParams: json['craftParams'] != null
          ? CraftParams.fromJson(json['craftParams'])
          : const CraftParams(),
      materials: List<String>.from(json['materials'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      orderCount: json['orderCount'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      isFeatured: json['isFeatured'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artisanId': artisanId,
      'title': title,
      'description': description,
      'category': category.name,
      'images': images,
      'coverImage': coverImage,
      'price': price,
      'originalPrice': originalPrice,
      'craftParams': craftParams.toJson(),
      'materials': materials,
      'tags': tags,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'orderCount': orderCount,
      'rating': rating,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? artisanId,
    String? title,
    String? description,
    ProductCategory? category,
    List<String>? images,
    String? coverImage,
    double? price,
    double? originalPrice,
    CraftParams? craftParams,
    List<String>? materials,
    List<String>? tags,
    int? viewCount,
    int? likeCount,
    int? orderCount,
    double? rating,
    bool? isFeatured,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      artisanId: artisanId ?? this.artisanId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      coverImage: coverImage ?? this.coverImage,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      craftParams: craftParams ?? this.craftParams,
      materials: materials ?? this.materials,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      orderCount: orderCount ?? this.orderCount,
      rating: rating ?? this.rating,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否有折扣
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// 折扣百分比
  int get discountPercent =>
      hasDiscount ? ((1 - price / originalPrice!) * 100).round() : 0;

  /// 首张图片
  String get firstImage => images.isNotEmpty ? images.first : '';
}
