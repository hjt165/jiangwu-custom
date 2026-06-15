/// 存证模型
/// 包含存证哈希、时间戳、凭证

/// 存证类型枚举
enum BlockchainType {
  orderCreated('订单创建'),
  orderSigned('订单签订'),
  stageDelivered('阶段交付'),
  finalDelivered('最终交付'),
  reviewCompleted('评价完成');

  final String label;
  const BlockchainType(this.label);

  static BlockchainType fromString(String value) {
    return BlockchainType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BlockchainType.orderCreated,
    );
  }
}

/// 存证记录模型
class BlockchainRecord {
  final String id;
  final String orderId;
  final BlockchainType type;
  final String transactionId;
  final String blockHash;
  final String dataHash;
  final Map<String, dynamic> evidenceData;
  final String? certificateUrl;
  final DateTime timestamp;
  final bool isVerified;

  const BlockchainRecord({
    required this.id,
    required this.orderId,
    required this.type,
    required this.transactionId,
    required this.blockHash,
    required this.dataHash,
    this.evidenceData = const {},
    this.certificateUrl,
    required this.timestamp,
    this.isVerified = false,
  });

  factory BlockchainRecord.fromJson(Map<String, dynamic> json) {
    return BlockchainRecord(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      type: BlockchainType.fromString(json['type'] ?? ''),
      transactionId: json['transactionId'] ?? '',
      blockHash: json['blockHash'] ?? '',
      dataHash: json['dataHash'] ?? '',
      evidenceData: json['evidenceData'] ?? {},
      certificateUrl: json['certificateUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'type': type.name,
      'transactionId': transactionId,
      'blockHash': blockHash,
      'dataHash': dataHash,
      'evidenceData': evidenceData,
      'certificateUrl': certificateUrl,
      'timestamp': timestamp.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  BlockchainRecord copyWith({
    String? id,
    String? orderId,
    BlockchainType? type,
    String? transactionId,
    String? blockHash,
    String? dataHash,
    Map<String, dynamic>? evidenceData,
    String? certificateUrl,
    DateTime? timestamp,
    bool? isVerified,
  }) {
    return BlockchainRecord(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      transactionId: transactionId ?? this.transactionId,
      blockHash: blockHash ?? this.blockHash,
      dataHash: dataHash ?? this.dataHash,
      evidenceData: evidenceData ?? this.evidenceData,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      timestamp: timestamp ?? this.timestamp,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// 获取哈希摘要（前8位+后8位）
  String get blockHashShort {
    if (blockHash.length <= 16) return blockHash;
    return '${blockHash.substring(0, 8)}...${blockHash.substring(blockHash.length - 8)}';
  }

  /// 获取数据哈希摘要
  String get dataHashShort {
    if (dataHash.length <= 16) return dataHash;
    return '${dataHash.substring(0, 8)}...${dataHash.substring(dataHash.length - 8)}';
  }
}

/// 存证凭证模型
class BlockchainCertificate {
  final String id;
  final String recordId;
  final String orderId;
  final String certificateNo;
  final String? certificateUrl;
  final String? qrCode;
  final DateTime issuedAt;
  final DateTime? expiresAt;

  const BlockchainCertificate({
    required this.id,
    required this.recordId,
    required this.orderId,
    required this.certificateNo,
    this.certificateUrl,
    this.qrCode,
    required this.issuedAt,
    this.expiresAt,
  });

  factory BlockchainCertificate.fromJson(Map<String, dynamic> json) {
    return BlockchainCertificate(
      id: json['id'] ?? '',
      recordId: json['recordId'] ?? '',
      orderId: json['orderId'] ?? '',
      certificateNo: json['certificateNo'] ?? '',
      certificateUrl: json['certificateUrl'],
      qrCode: json['qrCode'],
      issuedAt: DateTime.parse(json['issuedAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordId': recordId,
      'orderId': orderId,
      'certificateNo': certificateNo,
      'certificateUrl': certificateUrl,
      'qrCode': qrCode,
      'issuedAt': issuedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// 是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 有效期（天数）
  int get validityDays {
    if (expiresAt == null) return -1;
    return expiresAt!.difference(issuedAt).inDays;
  }
}
