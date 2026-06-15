import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/artisan_service.dart';

/// 手作人订单管理状态管理
/// 使用ChangeNotifier实现

class ArtisanOrderProvider extends ChangeNotifier {
  final ArtisanService _artisanService = ArtisanService();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  OrderStatus? _currentFilter;

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  OrderStatus? get currentFilter => _currentFilter;

  /// 获取订单列表
  Future<void> fetchOrders({
    OrderStatus? status,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _orders = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    _currentFilter = status;
    notifyListeners();

    try {
      final newOrders = await _artisanService.getOrders(
        status: status,
        page: _currentPage,
      );

      if (refresh) {
        _orders = newOrders;
      } else {
        _orders = [..._orders, ...newOrders];
      }

      _hasMore = newOrders.length >= 20;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 接受订单
  Future<bool> acceptOrder(String orderId) async {
    try {
      final success = await _artisanService.acceptOrder(orderId);
      if (success) {
        _orders.removeWhere((o) => o.id == orderId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 拒绝订单
  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    try {
      final success = await _artisanService.rejectOrder(orderId, reason: reason);
      if (success) {
        _orders.removeWhere((o) => o.id == orderId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 提交阶段交付
  Future<bool> submitStageDelivery(
    String orderId,
    String stageId, {
    required String note,
    required List<String> images,
  }) async {
    try {
      return await _artisanService.submitStageDelivery(
        orderId,
        stageId,
        note: note,
        images: images,
      );
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
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    _currentFilter = null;
    notifyListeners();
  }
}

/// 手作人订单管理Provider
final artisanOrderProvider = ChangeNotifierProvider<ArtisanOrderProvider>((ref) {
  return ArtisanOrderProvider();
});
