import 'dart:async';
import 'package:fluwx/fluwx.dart';
import 'package:flutter/services.dart';
import '../app/constants.dart';
import 'api_service.dart';

/// 微信支付服务
/// 封装fluwx，实现微信支付/退款功能

class PaymentService {
  // 单例模式
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final ApiService _apiService = ApiService();
  final Fluwx _fluwx = Fluwx();

  // 支付结果回调
  StreamController<PaymentResult>? _paymentController;
  Stream<PaymentResult>? _paymentStream;

  /// 初始化微信SDK
  Future<bool> init() async {
    try {
      final result = await _fluwx.registerApi(appId: ApiConstants.wechatAppId);
      return result;
    } catch (e) {
      print('微信SDK初始化失败: $e');
      return false;
    }
  }

  /// 检查微信是否已安装
  Future<bool> isWeChatInstalled() async {
    try {
      return await _fluwx.isWeChatInstalled;
    } catch (e) {
      print('检查微信安装状态失败: $e');
      return false;
    }
  }

  /// 发起微信支付
  /// [orderId] 订单ID
  /// [amount] 支付金额（元）
  /// [description] 支付描述
  Future<PaymentResult> pay({
    required String orderId,
    required double amount,
    required String description,
  }) async {
    _paymentController = StreamController<PaymentResult>.broadcast();
    _paymentStream = _paymentController!.stream;

    try {
      // 1. 检查微信是否安装
      final installed = await isWeChatInstalled();
      if (!installed) {
        return PaymentResult(
          success: false,
          errorCode: -1,
          errorMsg: '请先安装微信',
        );
      }

      // 2. 调用后端获取微信支付参数
      final response = await _apiService.post<Map<String, dynamic>>(
        '/payment/wechat/prepay',
        data: {
          'orderId': orderId,
          'amount': amount,
          'description': description,
        },
      );

      // 3. 监听微信支付回调并调起支付
      final completer = Completer<WeChatPaymentResponse>();
      final subscriber = _fluwx.addSubscriber((response) {
        if (response is WeChatPaymentResponse && !completer.isCompleted) {
          completer.complete(response);
        }
      });

      await _fluwx.pay(
        which: Payment(
          appId: response['appId'] ?? '',
          partnerId: response['partnerId'] ?? '',
          prepayId: response['prepayId'] ?? '',
          packageValue: response['package'] ?? 'Sign=WXPay',
          nonceStr: response['nonceStr'] ?? '',
          timestamp: int.parse(response['timestamp']?.toString() ?? '0'),
          sign: response['sign'] ?? '',
          extData: orderId,
        ),
      );

      // 4. 处理支付结果
      final wechatPayResult = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => WeChatPaymentResponse.fromMap({'errCode': -7, 'errStr': '支付超时'}),
      );
      subscriber.cancel();

      if (wechatPayResult.errCode == 0) {
        // 支付成功，通知后端
        await _apiService.post<void>(
          '/payment/wechat/notify',
          data: {
            'orderId': orderId,
            'transactionId': wechatPayResult.extData,
          },
        );

        return PaymentResult(
          success: true,
          errorCode: 0,
          errorMsg: '支付成功',
          transactionId: wechatPayResult.extData,
        );
      } else {
        return PaymentResult(
          success: false,
          errorCode: wechatPayResult.errCode ?? -1,
          errorMsg: _getWechatPayError(wechatPayResult.errCode ?? -1),
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        errorCode: -1,
        errorMsg: '支付异常: $e',
      );
    }
  }

  /// 查询订单支付状态
  Future<PaymentStatus> queryPaymentStatus(String orderId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/payment/status/$orderId',
      );

      return PaymentStatus(
        paid: response['paid'] ?? false,
        paidAmount: (response['paidAmount'] ?? 0).toDouble(),
        paidAt: response['paidAt'],
      );
    } catch (e) {
      return PaymentStatus(
        paid: false,
        paidAmount: 0,
      );
    }
  }

  /// 申请退款
  Future<RefundResult> refund({
    required String orderId,
    required double amount,
    required String reason,
  }) async {
    try {
      await _apiService.post<void>(
        '/payment/refund',
        data: {
          'orderId': orderId,
          'amount': amount,
          'reason': reason,
        },
      );

      return RefundResult(
        success: true,
        errorMsg: null,
      );
    } catch (e) {
      return RefundResult(
        success: false,
        errorMsg: '退款申请失败: $e',
      );
    }
  }

  /// 获取微信支付错误信息
  String _getWechatPayError(int errCode) {
    switch (errCode) {
      case -2:
        return '用户取消支付';
      case -3:
        return '支付失败';
      case -4:
        return '支付被拒绝';
      case -5:
        return '不支持的支付方式';
      case -6:
        return '不支持的API';
      case -7:
        return '支付超时';
      default:
        return '支付错误: $errCode';
    }
  }

  /// 释放资源
  void dispose() {
    _paymentController?.close();
  }
}

/// 支付结果
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

/// 支付状态
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

/// 退款结果
class RefundResult {
  final bool success;
  final String? errorMsg;

  RefundResult({
    required this.success,
    this.errorMsg,
  });
}
