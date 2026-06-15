import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/api_service.dart';

/// 订单状态管理
/// 使用ChangeNotifier实现

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取订单列表
  Future<void> fetchOrders({OrderStatus? status, bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<List<dynamic>>(
        '/order/list',
        queryParameters: {
          if (status != null) 'status': status.name,
        },
      );

      _orders = response.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取订单详情
  Future<void> fetchOrderDetail(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/order/$orderId',
      );

      _currentOrder = Order.fromJson(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建订单
  Future<Order?> createOrder({
    required String productId,
    required String artisanId,
    required Map<String, dynamic> customization,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/order/create',
        data: {
          'productId': productId,
          'artisanId': artisanId,
          'customization': customization,
          'amount': amount,
        },
      );

      final order = Order.fromJson(response);
      _orders.insert(0, order);
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 取消订单
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      await _apiService.put<void>(
        '/order/cancel',
        data: {'orderId': int.tryParse(orderId), 'reason': reason},
      );

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
        notifyListeners();
      }

      if (_currentOrder?.id == orderId) {
        _currentOrder = _currentOrder!.copyWith(status: OrderStatus.cancelled);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 确认阶段交付
  Future<bool> confirmStageDelivery(String orderId, String stageId, {
    String? feedback,
    List<String>? images,
  }) async {
    try {
      await _apiService.put<void>(
        '/order/stage/confirm',
        data: {
          'orderId': int.tryParse(orderId),
          'stageId': int.tryParse(stageId),
          'images': images ?? [],
          'note': feedback ?? '',
        },
      );

      await fetchOrderDetail(orderId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 提交评价
  Future<bool> submitReview(String orderId, {
    required double rating,
    required String content,
    List<String>? images,
    List<String>? tags,
  }) async {
    try {
      await _apiService.post<void>(
        '/order/review',
        data: {
          'orderId': int.tryParse(orderId),
          'rating': rating.round(),
          'content': content,
          'images': images ?? [],
          'tags': tags ?? [],
        },
      );

      await fetchOrderDetail(orderId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _orders = [];
    _currentOrder = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

/// 订单状态Provider
final orderProvider = ChangeNotifierProvider<OrderProvider>((ref) {
  return OrderProvider();
});