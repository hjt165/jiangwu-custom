/// 定制参数模型
/// 包含材质、尺寸、颜色、雕刻内容等定制参数

/// 定制参数模型
class Customization {
  final String id;
  final String productId;
  final String material;
  final String size;
  final String color;
  final String engraving;
  final String? description;
  final List<String> referenceImages;
  final Map<String, dynamic>? additionalParams;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customization({
    required this.id,
    this.productId = '',
    this.material = '',
    this.size = '',
    this.color = '',
    this.engraving = '',
    this.description,
    this.referenceImages = const [],
    this.additionalParams,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customization.fromJson(Map<String, dynamic> json) {
    return Customization(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      material: json['material'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      engraving: json['engraving'] ?? '',
      description: json['description'],
      referenceImages: List<String>.from(json['referenceImages'] ?? []),
      additionalParams: json['additionalParams'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'material': material,
      'size': size,
      'color': color,
      'engraving': engraving,
      'description': description,
      'referenceImages': referenceImages,
      'additionalParams': additionalParams,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Customization copyWith({
    String? id,
    String? productId,
    String? material,
    String? size,
    String? color,
    String? engraving,
    String? description,
    List<String>? referenceImages,
    Map<String, dynamic>? additionalParams,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customization(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      material: material ?? this.material,
      size: size ?? this.size,
      color: color ?? this.color,
      engraving: engraving ?? this.engraving,
      description: description ?? this.description,
      referenceImages: referenceImages ?? this.referenceImages,
      additionalParams: additionalParams ?? this.additionalParams,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否有雕刻内容
  bool get hasEngraving => engraving.isNotEmpty;

  /// 是否有参考图片
  bool get hasReferenceImages => referenceImages.isNotEmpty;

  /// 获取参数摘要
  String get summary {
    final parts = <String>[];
    if (material.isNotEmpty) parts.add('材质：$material');
    if (size.isNotEmpty) parts.add('尺寸：$size');
    if (color.isNotEmpty) parts.add('颜色：$color');
    if (engraving.isNotEmpty) parts.add('雕刻：$engraving');
    return parts.join(' | ');
  }
}

/// 材质选项
class MaterialOptions {
  MaterialOptions._();

  static const List<String> metals = [
    '925银',
    '999银',
    '18K金',
    'PT950铂金',
    '黄铜',
    '不锈钢',
  ];

  static const List<String> leathers = [
    '头层牛皮',
    '二层牛皮',
    '植鞣革',
    '铬鞣革',
    '羊皮',
    '猪皮',
  ];

  static const List<String> ceramics = [
    '高白瓷',
    '骨瓷',
    '紫砂',
    '陶土',
    '青瓷',
  ];

  static const List<String> woods = [
    '小叶紫檀',
    '黄花梨',
    '黑胡桃',
    '樱桃木',
    '橡木',
    '榉木',
  ];

  static const List<String> gems = [
    '翡翠',
    '和田玉',
    '玛瑙',
    '水晶',
    '珍珠',
    '琥珀',
  ];

  /// 获取所有材质选项
  static List<String> get all => [
        ...metals,
        ...leathers,
        ...ceramics,
        ...woods,
        ...gems,
      ];

  /// 根据分类获取材质选项
  static List<String> getByCategory(String category) {
    switch (category) {
      case '首饰':
        return [...metals, ...gems];
      case '皮具':
        return leathers;
      case '陶瓷':
        return ceramics;
      case '木艺':
        return woods;
      default:
        return all;
    }
  }
}

/// 尺寸选项
class SizeOptions {
  SizeOptions._();

  static const List<String> ring = [
    '10号',
    '11号',
    '12号',
    '13号',
    '14号',
    '15号',
    '16号',
    '17号',
    '18号',
    '19号',
    '20号',
    '21号',
  ];

  static const List<String> bracelet = [
    'S (14-15cm)',
    'M (15-16cm)',
    'L (16-17cm)',
    'XL (17-18cm)',
    'XXL (18-19cm)',
    '可调节',
  ];

  static const List<String> necklace = [
    '40cm (锁骨链)',
    '45cm (标准)',
    '50cm (中长)',
    '60cm (长款)',
    '可调节',
  ];

  static const List<String> general = [
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    '可调节',
    '定制尺寸',
  ];
}

/// 颜色选项
class ColorOptions {
  ColorOptions._();

  static const Map<String, String> metalColors = {
    '银白': '#C0C0C0',
    '金色': '#FFD700',
    '玫瑰金': '#B76E79',
    '古铜': '#CD7F32',
    '枪黑': '#2C3E50',
  };

  static const Map<String, String> leatherColors = {
    '原色': '#D2B48C',
    '黑色': '#000000',
    '棕色': '#8B4513',
    '深棕': '#654321',
    '酒红': '#722F37',
    '墨绿': '#013220',
  };

  static const Map<String, String> ceramicColors = {
    '白色': '#FFFFFF',
    '青色': '#00CED1',
    '蓝色': '#0000FF',
    '粉色': '#FFB6C1',
    '黑色': '#000000',
  };

  static const Map<String, String> woodColors = {
    '原木色': '#DEB887',
    '浅棕': '#D2691E',
    '深棕': '#8B4513',
    '红木色': '#800000',
    '黑檀': '#0C0C0C',
  };

  /// 获取所有颜色
  static Map<String, String> get all => {
        ...metalColors,
        ...leatherColors,
        ...ceramicColors,
        ...woodColors,
      };
}
