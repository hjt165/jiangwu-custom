import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// 浏览历史状态管理
class HistoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _historyProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get historyProducts => _historyProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _historyProducts.length;

  /// 加载浏览历史
  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getHistoryList();
      _historyProducts = response.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 记录浏览
  Future<void> recordView(String productId) async {
    try {
      await _apiService.recordBrowseHistory(productId);
    } catch (e) {
      // 浏览记录失败不影响主流程
    }
  }

  /// 清空浏览历史
  Future<void> clearHistory() async {
    try {
      await _apiService.clearHistory();
      _historyProducts.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

final historyProvider = ChangeNotifierProvider<HistoryProvider>((ref) {
  return HistoryProvider();
});
