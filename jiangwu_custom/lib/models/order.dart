/// 订单模型
/// 包含订单状态、金额、时间线、定制参数

import 'customization.dart';
import 'product.dart';
import 'artisan.dart';
import 'review.dart';

/// 订单状态枚举
enum OrderStatus {
  pendingPayment('待支付'),
  paid('已支付'),
  producing('制作中'),
  stageDelivering('阶段交付中'),
  completed('已完成'),
  cancelled('已取消'),
  refunding('退款中'),
  delayed('延期中'),
  disputed('争议中');

  final String label;
  const OrderStatus(this.label);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pendingPayment,
    );
  }
}

/// 订单阶段
class OrderStage {
  final String id;
  final String name;
  final String description;
  final OrderStatus status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String> deliverImages;
  final String? deliverNote;

  const OrderStage({
    required this.id,
    required this.name,
    this.description = '',
    this.status = OrderStatus.pendingPayment,
    this.dueDate,
    this.completedAt,
    this.deliverImages = const [],
    this.deliverNote,
  });

  factory OrderStage.fromJson(Map<String, dynamic> json) {
    return OrderStage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: OrderStatus.fromString(json['status'] ?? ''),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      deliverImages: List<String>.from(json['deliverImages'] ?? []),
      deliverNote: json['deliverNote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'deliverImages': deliverImages,
      'deliverNote': deliverNote,
    };
  }

  OrderStage copyWith({
    String? id,
    String? name,
    String? description,
    OrderStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? deliverImages,
    String? deliverNote,
  }) {
    return OrderStage(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      deliverImages: deliverImages ?? this.deliverImages,
      deliverNote: deliverNote ?? this.deliverNote,
    );
  }
}

/// 订单模型
class Order {
  final String id;
  final String orderNo;
  final String userId;
  final String artisanId;
  final Product? product;
  final Artisan? artisan;
  final Customization? customization;
  final OrderStatus status;
  final double totalAmount;
  final double paidAmount;
  final double depositAmount;
  final List<OrderStage> stages;
  final int currentStage;
  final Review? review;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;
  final DateTime? completedAt;

  const Order({
    required this.id,
    required this.orderNo,
    required this.userId,
    required this.artisanId,
    this.product,
    this.artisan,
    this.customization,
    this.status = OrderStatus.pendingPayment,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.depositAmount = 0,
    this.stages = const [],
    this.currentStage = 0,
    this.review,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.completedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      orderNo: json['orderNo'] ?? '',
      userId: json['userId'] ?? '',
      artisanId: json['artisanId'] ?? '',
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      artisan: json['artisan'] != null ? Artisan.fromJson(json['artisan']) : null,
      customization: json['customization'] != null ? Customization.fromJson(json['customization']) : null,
      status: OrderStatus.fromString(json['status'] ?? ''),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      depositAmount: (json['depositAmount'] ?? 0).toDouble(),
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) => OrderStage.fromJson(e))
              .toList() ??
          [],
      currentStage: json['currentStage'] ?? 0,
      review: json['review'] != null ? Review.fromJson(json['review']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'userId': userId,
      'artisanId': artisanId,
      'product': product?.toJson(),
      'artisan': artisan?.toJson(),
      'customization': customization?.toJson(),
      'status': status.name,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'depositAmount': depositAmount,
      'stages': stages.map((e) => e.toJson()).toList(),
      'currentStage': currentStage,
      'review': review?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    String? orderNo,
    String? userId,
    String? artisanId,
    Product? product,
    Artisan? artisan,
    Customization? customization,
    OrderStatus? status,
    double? totalAmount,
    double? paidAmount,
    double? depositAmount,
    List<OrderStage>? stages,
    int? currentStage,
    Review? review,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      userId: userId ?? this.userId,
      artisanId: artisanId ?? this.artisanId,
      product: product ?? this.product,
      artisan: artisan ?? this.artisan,
      customization: customization ?? this.customization,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      stages: stages ?? this.stages,
      currentStage: currentStage ?? this.currentStage,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// 获取当前阶段
  OrderStage? get currentStageDetail {
    if (stages.isEmpty || currentStage >= stages.length) return null;
    return stages[currentStage];
  }

  /// 是否可取消
  bool get canCancel => status == OrderStatus.pendingPayment;

  /// 是否可支付
  bool get canPay => status == OrderStatus.pendingPayment;

  /// 是否可确认收货
  bool get canConfirm =>
      status == OrderStatus.stageDelivering ||
      status == OrderStatus.producing;
}
