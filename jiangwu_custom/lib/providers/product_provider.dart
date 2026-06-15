import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// 作品状态管理
/// 使用ChangeNotifier实现

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  Product? _currentProduct;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  Product? get currentProduct => _currentProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  /// 获取推荐作品（首页用）
  Future<void> fetchFeaturedProducts() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/product/featured',
      );

      _featuredProducts = response.map((e) => Product.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 获取作品列表
  Future<void> fetchProducts({
    String? category,
    bool refresh = false,
  }) async {
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
      final response = await _apiService.get<List<dynamic>>(
        '/product/list',
        queryParameters: {
          'page': _currentPage,
          'size': 20,
          if (category != null) 'category': category,
        },
      );

      final newProducts = response.map((e) => Product.fromJson(e)).toList();

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

  /// 获取作品详情
  Future<void> fetchProductDetail(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/product/$productId',
      );

      _currentProduct = Product.fromJson(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 搜索作品
  Future<void> searchProducts(String keyword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<List<dynamic>>(
        '/product/search',
        queryParameters: {
          'keyword': keyword,
          'page': 1,
          'size': 20,
        },
      );

      _products = response.map((e) => Product.fromJson(e)).toList();
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
    _products = [];
    _featuredProducts = [];
    _currentProduct = null;
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}

/// 作品状态Provider
final productProvider = ChangeNotifierProvider<ProductProvider>((ref) {
  return ProductProvider();
});