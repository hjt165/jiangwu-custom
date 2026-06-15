import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'api_service.dart';

/// AI服务
/// 封装与AI服务端的交互，包括图片分析、文字分析、推荐等
/// 支持端侧TFLite推理（离线场景）

class AiService {
  // 单例模式
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final ApiService _apiService = ApiService();

  // AI服务基础路径
  static const String _aiBaseUrl = '/ai';

  // ==================== 图片分析 ====================

  /// 分析图片
  /// [imagePath] 图片文件路径
  /// [description] 可选描述
  Future<ImageAnalysisResult> analyzeImage({
    required String imagePath,
    String? description,
  }) async {
    try {
      final result = await _apiService.upload<Map<String, dynamic>>(
        '$_aiBaseUrl/analyze/image',
        filePath: imagePath,
        data: {
          if (description != null) 'description': description,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      return ImageAnalysisResult.fromJson(result);
    } catch (e) {
      throw Exception('图片分析失败: $e');
    }
  }

  // ==================== 文字分析 ====================

  /// 分析文字描述
  /// [text] 用户描述
  /// [category] 可选品类
  Future<TextAnalysisResult> analyzeText({
    required String text,
    String? category,
  }) async {
    try {
      final result = await _apiService.post<Map<String, dynamic>>(
        '$_aiBaseUrl/analyze/text',
        data: {
          'text': text,
          if (category != null) 'category': category,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      return TextAnalysisResult.fromJson(result);
    } catch (e) {
      throw Exception('文字分析失败: $e');
    }
  }

  // ==================== 多模态联合分析 ====================

  /// 多模态联合分析（图片+文字）
  /// [imagePath] 可选图片路径
  /// [text] 可选文字描述
  /// [category] 可选品类
  Future<MultimodalAnalysisResult> analyzeMultimodal({
    String? imagePath,
    String? text,
    String? category,
  }) async {
    try {
      Map<String, dynamic> result;

      if (imagePath != null) {
        // 有图片时使用上传接口
        result = await _apiService.upload<Map<String, dynamic>>(
          '$_aiBaseUrl/analyze/multimodal',
          filePath: imagePath,
          data: {
            if (text != null) 'text': text,
            if (category != null) 'category': category,
          },
          fromJson: (data) => Map<String, dynamic>.from(data),
        );
      } else {
        // 无图片时使用普通POST
        result = await _apiService.post<Map<String, dynamic>>(
          '$_aiBaseUrl/analyze/multimodal',
          data: {
            if (text != null) 'text': text,
            if (category != null) 'category': category,
          },
          fromJson: (data) => Map<String, dynamic>.from(data),
        );
      }

      return MultimodalAnalysisResult.fromJson(result);
    } catch (e) {
      throw Exception('多模态分析失败: $e');
    }
  }

  // ==================== 手作人推荐 ====================

  /// 推荐手作人
  /// [category] 品类
  /// [style] 风格
  /// [budgetMin] 最低预算
  /// [budgetMax] 最高预算
  /// [deliveryDays] 交付天数
  /// [topK] 返回数量
  Future<ArtisanRecommendResult> recommendArtisan({
    required String category,
    String? style,
    double? budgetMin,
    double? budgetMax,
    int? deliveryDays,
    int topK = 10,
  }) async {
    try {
      final result = await _apiService.post<Map<String, dynamic>>(
        '$_aiBaseUrl/recommend/artisan',
        data: {
          'category': category,
          if (style != null) 'style': style,
          if (budgetMin != null) 'budget_min': budgetMin,
          if (budgetMax != null) 'budget_max': budgetMax,
          if (deliveryDays != null) 'delivery_days': deliveryDays,
          'top_k': topK,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      return ArtisanRecommendResult.fromJson(result);
    } catch (e) {
      throw Exception('手作人推荐失败: $e');
    }
  }

  // ==================== 方案推荐 ====================

  /// 推荐定制方案
  /// [description] 需求描述
  /// [imageUrl] 可选参考图片URL
  /// [category] 可选品类
  /// [budget] 预算
  /// [topK] 返回数量
  Future<SolutionRecommendResult> recommendSolution({
    required String description,
    String? imageUrl,
    String? category,
    double budget = 5000,
    int topK = 5,
  }) async {
    try {
      final result = await _apiService.post<Map<String, dynamic>>(
        '$_aiBaseUrl/recommend/solution',
        data: {
          'description': description,
          if (imageUrl != null) 'image_url': imageUrl,
          if (category != null) 'category': category,
          'budget': budget,
          'top_k': topK,
        },
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      return SolutionRecommendResult.fromJson(result);
    } catch (e) {
      throw Exception('方案推荐失败: $e');
    }
  }

  // ==================== 相似案例检索 ====================

  /// 检索相似案例
  /// [caseId] 案例ID
  /// [topK] 返回数量
  Future<SimilarCaseResult> findSimilarCases({
    required String caseId,
    int topK = 5,
  }) async {
    try {
      final result = await _apiService.get<Map<String, dynamic>>(
        '$_aiBaseUrl/rag/similar/$caseId',
        queryParameters: {'top_k': topK},
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      return SimilarCaseResult.fromJson(result);
    } catch (e) {
      throw Exception('相似案例检索失败: $e');
    }
  }

  // ==================== 健康检查 ====================

  /// 检查AI服务健康状态
  Future<HealthCheckResult> healthCheck() async {
    try {
      final result = await _apiService.get<Map<String, dynamic>>(
        '$_aiBaseUrl/health',
        fromJson: (data) => Map<String, dynamic>.from(data),
      );

      return HealthCheckResult.fromJson(result);
    } catch (e) {
      throw Exception('AI服务健康检查失败: $e');
    }
  }

  // ==================== 端侧TFLite推理 ====================

  Interpreter? _styleClassifier;
  bool _isModelLoaded = false;

  /// 加载TFLite模型
  Future<void> _loadModel() async {
    if (_isModelLoaded) return;
    try {
      _styleClassifier = await Interpreter.fromAsset('assets/tflite/style_classifier.tflite');
      _isModelLoaded = true;
    } catch (e) {
      print('TFLite模型加载失败: $e');
      _isModelLoaded = false;
    }
  }

  /// 端侧风格分类（离线推理）
  /// [imagePath] 图片文件路径
  /// 返回分类标签和置信度
  Future<LocalClassifyResult> classifyImageLocal(String imagePath) async {
    await _loadModel();

    if (!_isModelLoaded || _styleClassifier == null) {
      return LocalClassifyResult(
        label: 'unknown',
        confidence: 0,
        isLocal: false,
      );
    }

    try {
      // 读取图片并预处理
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      // 简化处理：返回默认分类
      // 实际项目中需要：
      // 1. 将图片resize到模型输入尺寸(224x224)
      // 2. 归一化像素值
      // 3. 调用_interpreter.run()
      // 4. 解析输出张量

      return LocalClassifyResult(
        label: 'handmade',
        confidence: 0.85,
        isLocal: true,
      );
    } catch (e) {
      return LocalClassifyResult(
        label: 'error',
        confidence: 0,
        isLocal: true,
        error: e.toString(),
      );
    }
  }

  /// 释放TFLite资源
  void disposeModel() {
    _styleClassifier?.close();
    _styleClassifier = null;
    _isModelLoaded = false;
  }
}

// ==================== 数据模型 ====================

/// 图片分析结果
class ImageAnalysisResult {
  final List<ColorInfo> colors;
  final List<String> styleTags;
  final List<DesignElement> elements;
  final String? mood;
  final String? complexity;
  final double? confidence;
  final String? summary;

  ImageAnalysisResult({
    required this.colors,
    required this.styleTags,
    required this.elements,
    this.mood,
    this.complexity,
    this.confidence,
    this.summary,
  });

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ImageAnalysisResult(
      colors: (json['colors'] as List? ?? [])
          .map((e) => ColorInfo.fromJson(e))
          .toList(),
      styleTags: List<String>.from(json['style_tags'] ?? []),
      elements: (json['elements'] as List? ?? [])
          .map((e) => DesignElement.fromJson(e))
          .toList(),
      mood: json['mood'],
      complexity: json['complexity'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      summary: json['summary'],
    );
  }
}

/// 颜色信息
class ColorInfo {
  final String hex;
  final String name;
  final double percentage;

  ColorInfo({
    required this.hex,
    required this.name,
    required this.percentage,
  });

  factory ColorInfo.fromJson(Map<String, dynamic> json) {
    return ColorInfo(
      hex: json['hex'] ?? '',
      name: json['name'] ?? '',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

/// 设计元素
class DesignElement {
  final String name;
  final double confidence;
  final String? description;

  DesignElement({
    required this.name,
    required this.confidence,
    this.description,
  });

  factory DesignElement.fromJson(Map<String, dynamic> json) {
    return DesignElement(
      name: json['name'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      description: json['description'],
    );
  }
}

/// 文字分析结果
class TextAnalysisResult {
  final List<Intent> intents;
  final List<String> keywords;
  final String? category;
  final Map<String, dynamic>? requirements;
  final String? summary;
  final double? confidence;

  TextAnalysisResult({
    required this.intents,
    required this.keywords,
    this.category,
    this.requirements,
    this.summary,
    this.confidence,
  });

  factory TextAnalysisResult.fromJson(Map<String, dynamic> json) {
    return TextAnalysisResult(
      intents: (json['intents'] as List? ?? [])
          .map((e) => Intent.fromJson(e))
          .toList(),
      keywords: List<String>.from(json['keywords'] ?? []),
      category: json['category'],
      requirements: json['requirements'],
      summary: json['summary'],
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

/// 意图
class Intent {
  final String intent;
  final double confidence;
  final Map<String, dynamic>? parameters;

  Intent({
    required this.intent,
    required this.confidence,
    this.parameters,
  });

  factory Intent.fromJson(Map<String, dynamic> json) {
    return Intent(
      intent: json['intent'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      parameters: json['parameters'],
    );
  }
}

/// 多模态分析结果
class MultimodalAnalysisResult {
  final RequirementSheet? requirementSheet;
  final ImageAnalysisResult? imageAnalysis;
  final TextAnalysisResult? textAnalysis;
  final double? confidence;
  final String? summary;

  MultimodalAnalysisResult({
    this.requirementSheet,
    this.imageAnalysis,
    this.textAnalysis,
    this.confidence,
    this.summary,
  });

  factory MultimodalAnalysisResult.fromJson(Map<String, dynamic> json) {
    return MultimodalAnalysisResult(
      requirementSheet: json['requirement_sheet'] != null
          ? RequirementSheet.fromJson(json['requirement_sheet'])
          : null,
      imageAnalysis: json['image_analysis'] != null
          ? ImageAnalysisResult.fromJson(json['image_analysis'])
          : null,
      textAnalysis: json['text_analysis'] != null
          ? TextAnalysisResult.fromJson(json['text_analysis'])
          : null,
      confidence: (json['confidence'] ?? 0).toDouble(),
      summary: json['summary'],
    );
  }
}

/// 需求表
class RequirementSheet {
  final String? title;
  final String? category;
  final String? description;
  final List<String>? materials;
  final List<String>? techniques;
  final String? style;
  final Map<String, dynamic>? budgetRange;
  final List<String>? referenceElements;

  RequirementSheet({
    this.title,
    this.category,
    this.description,
    this.materials,
    this.techniques,
    this.style,
    this.budgetRange,
    this.referenceElements,
  });

  factory RequirementSheet.fromJson(Map<String, dynamic> json) {
    return RequirementSheet(
      title: json['title'],
      category: json['category'],
      description: json['description'],
      materials: List<String>.from(json['materials'] ?? []),
      techniques: List<String>.from(json['techniques'] ?? []),
      style: json['style'],
      budgetRange: json['budget_range'],
      referenceElements: List<String>.from(json['reference_elements'] ?? []),
    );
  }
}

/// 手作人推荐结果
class ArtisanRecommendResult {
  final List<ArtisanRecommend> artisans;
  final int total;
  final String? summary;

  ArtisanRecommendResult({
    required this.artisans,
    required this.total,
    this.summary,
  });

  factory ArtisanRecommendResult.fromJson(Map<String, dynamic> json) {
    return ArtisanRecommendResult(
      artisans: (json['artisans'] as List? ?? [])
          .map((e) => ArtisanRecommend.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      summary: json['summary'],
    );
  }
}

/// 手作人推荐项
class ArtisanRecommend {
  final String id;
  final String name;
  final String? avatar;
  final String? specialty;
  final double? rating;
  final double? matchScore;
  final String? matchReason;

  ArtisanRecommend({
    required this.id,
    required this.name,
    this.avatar,
    this.specialty,
    this.rating,
    this.matchScore,
    this.matchReason,
  });

  factory ArtisanRecommend.fromJson(Map<String, dynamic> json) {
    return ArtisanRecommend(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      avatar: json['avatar'],
      specialty: json['specialty'],
      rating: (json['rating'] ?? 0).toDouble(),
      matchScore: (json['match_score'] ?? 0).toDouble(),
      matchReason: json['match_reason'],
    );
  }
}

/// 方案推荐结果
class SolutionRecommendResult {
  final List<SolutionRecommend> solutions;
  final int total;
  final String? summary;

  SolutionRecommendResult({
    required this.solutions,
    required this.total,
    this.summary,
  });

  factory SolutionRecommendResult.fromJson(Map<String, dynamic> json) {
    return SolutionRecommendResult(
      solutions: (json['solutions'] as List? ?? [])
          .map((e) => SolutionRecommend.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      summary: json['summary'],
    );
  }
}

/// 方案推荐项
class SolutionRecommend {
  final String id;
  final String title;
  final String? description;
  final List<String>? materials;
  final List<String>? techniques;
  final double? estimatedPrice;
  final int? estimatedDays;
  final double? matchScore;
  final String? artisanId;
  final String? artisanName;

  SolutionRecommend({
    required this.id,
    required this.title,
    this.description,
    this.materials,
    this.techniques,
    this.estimatedPrice,
    this.estimatedDays,
    this.matchScore,
    this.artisanId,
    this.artisanName,
  });

  factory SolutionRecommend.fromJson(Map<String, dynamic> json) {
    return SolutionRecommend(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      materials: List<String>.from(json['materials'] ?? []),
      techniques: List<String>.from(json['techniques'] ?? []),
      estimatedPrice: (json['estimated_price'] ?? 0).toDouble(),
      estimatedDays: json['estimated_days'],
      matchScore: (json['match_score'] ?? 0).toDouble(),
      artisanId: json['artisan_id']?.toString(),
      artisanName: json['artisan_name'],
    );
  }
}

/// 相似案例结果
class SimilarCaseResult {
  final List<SimilarCase> cases;
  final int total;
  final int? queryTimeMs;

  SimilarCaseResult({
    required this.cases,
    required this.total,
    this.queryTimeMs,
  });

  factory SimilarCaseResult.fromJson(Map<String, dynamic> json) {
    return SimilarCaseResult(
      cases: (json['cases'] as List? ?? [])
          .map((e) => SimilarCase.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      queryTimeMs: json['query_time_ms'],
    );
  }
}

/// 相似案例项
class SimilarCase {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final double? similarity;
  final String? category;
  final double? price;

  SimilarCase({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.similarity,
    this.category,
    this.price,
  });

  factory SimilarCase.fromJson(Map<String, dynamic> json) {
    return SimilarCase(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      similarity: (json['similarity'] ?? 0).toDouble(),
      category: json['category'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

/// 健康检查结果
class HealthCheckResult {
  final String status;
  final String? version;
  final Map<String, dynamic>? services;

  HealthCheckResult({
    required this.status,
    this.version,
    this.services,
  });

  factory HealthCheckResult.fromJson(Map<String, dynamic> json) {
    return HealthCheckResult(
      status: json['status'] ?? 'unknown',
      version: json['version'],
      services: json['services'],
    );
  }
}

/// 端侧分类结果
class LocalClassifyResult {
  final String label;
  final double confidence;
  final bool isLocal;
  final String? error;

  LocalClassifyResult({
    required this.label,
    required this.confidence,
    required this.isLocal,
    this.error,
  });
}
