import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/artisan_service.dart';

/// 手作人工作台状态管理
/// 使用ChangeNotifier实现

class ArtisanWorkspaceProvider extends ChangeNotifier {
  final ArtisanService _artisanService = ArtisanService();

  Map<String, dynamic> _stats = {
    'pendingOrders': 0,
    'todayOrders': 0,
    'monthIncome': 0.0,
    'totalWorks': 0,
  };
  List<Order> _pendingOrders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic> get stats => _stats;
  List<Order> get pendingOrders => _pendingOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取工作台数据
  Future<void> fetchWorkspaceData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _artisanService.getWorkspaceStats(),
        _artisanService.getPendingOrders(),
      ]);

      _stats = results[0] as Map<String, dynamic>;
      _pendingOrders = results[1] as List<Order>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _stats = {
      'pendingOrders': 0,
      'todayOrders': 0,
      'monthIncome': 0.0,
      'totalWorks': 0,
    };
    _pendingOrders = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

/// 手作人工作台Provider
final artisanWorkspaceProvider = ChangeNotifierProvider<ArtisanWorkspaceProvider>((ref) {
  return ArtisanWorkspaceProvider();
});
