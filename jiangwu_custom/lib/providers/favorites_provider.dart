import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';

/// 收藏状态管理
class FavoritesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _favoriteProducts = [];
  List<Map<String, dynamic>> _favoriteArtisans = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get favoriteProducts => _favoriteProducts;
  List<Map<String, dynamic>> get favoriteArtisans => _favoriteArtisans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _favoriteProducts.length;

  /// 加载收藏列表
  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getFavoriteList();
      _favoriteProducts = response.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载收藏的手作人列表
  Future<void> loadFavoriteArtisans() async {
    try {
      final response = await _apiService.getFollowList();
      _favoriteArtisans = response.cast<Map<String, dynamic>>();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 添加收藏
  Future<void> addFavorite(String productId) async {
    try {
      await _apiService.addFavorite(productId);
      // 重新加载列表
      await loadFavorites();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 取消收藏
  Future<void> removeFavorite(String productId) async {
    try {
      await _apiService.removeFavorite(productId);
      _favoriteProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(String productId) async {
    try {
      final isFavorited = await _apiService.toggleFavorite(productId);
      if (isFavorited) {
        // 重新加载以获取完整数据
        await loadFavorites();
      } else {
        _favoriteProducts.removeWhere((p) => p.id == productId);
        notifyListeners();
      }
      return isFavorited;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 检查是否已收藏
  Future<bool> isFavorited(String productId) async {
    try {
      return await _apiService.checkFavorite(productId);
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

final favoritesProvider = ChangeNotifierProvider<FavoritesProvider>((ref) {
  return FavoritesProvider();
});
