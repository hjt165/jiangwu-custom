import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/artisan_service.dart';

/// 手作人作品管理状态管理
/// 使用ChangeNotifier实现

class ArtisanProductProvider extends ChangeNotifier {
  final ArtisanService _artisanService = ArtisanService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  /// 获取作品列表
  Future<void> fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _products = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProducts = await _artisanService.getProducts(page: _currentPage);

      if (refresh) {
        _products = newProducts;
      } else {
        _products = [..._products, ...newProducts];
      }

      _hasMore = newProducts.length >= 20;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 发布新作品
  Future<Product?> createProduct(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _artisanService.createProduct(data);
      if (product != null) {
        _products.insert(0, product);
        notifyListeners();
      }
      return product;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新作品信息
  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      final success = await _artisanService.updateProduct(productId, data);
      if (success) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          // 刷新列表中的作品
          await fetchProducts(refresh: true);
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 切换作品上下架状态
  Future<bool> toggleProductStatus(String productId) async {
    try {
      final success = await _artisanService.toggleProductStatus(productId);
      if (success) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(
            isAvailable: !_products[index].isAvailable,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 删除作品
  Future<bool> deleteProduct(String productId) async {
    try {
      final success = await _artisanService.deleteProduct(productId);
      if (success) {
        _products.removeWhere((p) => p.id == productId);
        notifyListeners();
      }
      return success;
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
    _products = [];
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}

/// 手作人作品管理Provider
final artisanProductProvider = ChangeNotifierProvider<ArtisanProductProvider>((ref) {
  return ArtisanProductProvider();
});
