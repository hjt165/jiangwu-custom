import 'dart:async';
import 'dart:developer' as developer;

/// 微信支付服务 (Mock模式 - fluwx暂未兼容Kotlin 2.x)
/// 保持接口不变

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  StreamController<PaymentResult>? _paymentController;
  Stream<PaymentResult>? _paymentStream;

  Future<bool> init() async {
    developer.log('PaymentService: 微信支付服务已禁用(mock模式)');
    return true;
  }

  Future<bool> isWeChatInstalled() async {
    return false;
  }

  Future<PaymentResult> pay({
    required String orderId,
    required double amount,
    required String description,
  }) async {
    return PaymentResult(
      success: false,
      errorCode: -1,
      errorMsg: '微信支付暂不可用(mock模式)',
    );
  }

  Future<PaymentStatus> queryPaymentStatus(String orderId) async {
    return PaymentStatus(paid: false, paidAmount: 0);
  }

  Future<RefundResult> refund({
    required String orderId,
    required double amount,
    required String reason,
  }) async {
    return RefundResult(
      success: false,
      errorMsg: '退款功能暂不可用(mock模式)',
    );
  }

  void dispose() {
    _paymentController?.close();
  }
}

class PaymentResult {
  final bool success;
  final int errorCode;
  final String errorMsg;
  final String? transactionId;

  PaymentResult({
    required this.success,
    required this.errorCode,
    required this.errorMsg,
    this.transactionId,
  });
}

class PaymentStatus {
  final bool paid;
  final double paidAmount;
  final String? paidAt;

  PaymentStatus({
    required this.paid,
    required this.paidAmount,
    this.paidAt,
  });
}

class RefundResult {
  final bool success;
  final String? errorMsg;

  RefundResult({
    required this.success,
    this.errorMsg,
  });
}
