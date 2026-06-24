import 'package:dio/dio.dart';
import 'api_service.dart';

/// 区块链溯源服务
/// 提供订单存证记录查询、真伪验证等功能

class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  final ApiService _apiService = ApiService();

  /// 获取订单溯源记录列表
  Future<List<BlockchainRecord>> getRecords(String orderId) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/blockchain/records',
        queryParameters: {'orderId': orderId},
      );
      return response.map((e) => BlockchainRecord.fromJson(e)).toList();
    } on DioException {
      rethrow;
    }
  }

  /// 获取溯源记录详情
  Future<BlockchainRecord> getRecordDetail(String recordId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/blockchain/record/$recordId',
      );
      return BlockchainRecord.fromJson(response);
    } on DioException {
      rethrow;
    }
  }

  /// 验证存证真伪
  Future<VerifyResult> verifyRecord(String recordId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/blockchain/verify',
        data: {'recordId': recordId},
      );
      return VerifyResult.fromJson(response);
    } on DioException {
      rethrow;
    }
  }

  /// 获取订单完整溯源链
  Future<TraceChain> getTraceChain(String orderId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/blockchain/trace',
        queryParameters: {'orderId': orderId},
      );
      return TraceChain.fromJson(response);
    } on DioException {
      rethrow;
    }
  }

  /// 下载存证证书
  Future<String> downloadCertificate(String recordId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/blockchain/certificate',
        queryParameters: {'recordId': recordId},
      );
      return response['certificateUrl'] ?? '';
    } on DioException {
      rethrow;
    }
  }
}

/// 区块链存证记录
class BlockchainRecord {
  final String id;
  final String orderId;
  final String type;
  final String? transactionId;
  final String? blockHash;
  final String? dataHash;
  final Map<String, dynamic>? evidenceData;
  final String? certificateUrl;
  final String? timestamp;
  final bool isVerified;
  final String? createdAt;

  BlockchainRecord({
    required this.id,
    required this.orderId,
    required this.type,
    this.transactionId,
    this.blockHash,
    this.dataHash,
    this.evidenceData,
    this.certificateUrl,
    this.timestamp,
    this.isVerified = false,
    this.createdAt,
  });

  factory BlockchainRecord.fromJson(Map<String, dynamic> json) {
    return BlockchainRecord(
      id: (json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      type: json['type'] ?? '',
      transactionId: json['transactionId'],
      blockHash: json['blockHash'],
      dataHash: json['dataHash'],
      evidenceData: json['evidenceData'],
      certificateUrl: json['certificateUrl'],
      timestamp: json['timestamp'],
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'type': type,
      'transactionId': transactionId,
      'blockHash': blockHash,
      'dataHash': dataHash,
      'evidenceData': evidenceData,
      'certificateUrl': certificateUrl,
      'timestamp': timestamp,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
  }
}

/// 验证结果
class VerifyResult {
  final bool valid;
  final String? message;
  final String? verifiedAt;
  final String? blockHash;

  VerifyResult({
    required this.valid,
    this.message,
    this.verifiedAt,
    this.blockHash,
  });

  factory VerifyResult.fromJson(Map<String, dynamic> json) {
    return VerifyResult(
      valid: json['valid'] ?? false,
      message: json['message'],
      verifiedAt: json['verifiedAt'],
      blockHash: json['blockHash'],
    );
  }
}

/// 溯源链
class TraceChain {
  final String orderId;
  final List<BlockchainRecord> records;
  final int totalSteps;
  final int verifiedSteps;

  TraceChain({
    required this.orderId,
    required this.records,
    required this.totalSteps,
    required this.verifiedSteps,
  });

  factory TraceChain.fromJson(Map<String, dynamic> json) {
    return TraceChain(
      orderId: (json['orderId'] ?? '').toString(),
      records: (json['records'] as List<dynamic>?)
              ?.map((e) => BlockchainRecord.fromJson(e))
              .toList() ??
          [],
      totalSteps: json['totalSteps'] ?? 0,
      verifiedSteps: json['verifiedSteps'] ?? 0,
    );
  }
}
