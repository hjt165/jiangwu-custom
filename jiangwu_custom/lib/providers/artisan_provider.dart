import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/artisan.dart';
import '../services/api_service.dart';

/// 手作人状态管理
/// 使用ChangeNotifier实现

class ArtisanProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Artisan> _artisans = [];
  Artisan? _currentArtisan;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Artisan> get artisans => _artisans;
  Artisan? get currentArtisan => _currentArtisan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取手作人列表
  Future<void> fetchArtisans({
    String? category,
    String? keyword,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<dynamic> response;

      if (keyword != null && keyword.isNotEmpty) {
        // 搜索手作人
        response = await _apiService.get<List<dynamic>>(
          '/artisan/search',
          queryParameters: {'keyword': keyword},
        );
      } else {
        // 获取手作人列表
        response = await _apiService.get<List<dynamic>>(
          '/artisan/list',
        );
      }

      _artisans = response.map((e) => Artisan.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取手作人详情
  Future<void> fetchArtisanDetail(String artisanId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/artisan/',
      );

      _currentArtisan = Artisan.fromJson(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 搜索手作人
  Future<void> searchArtisans(String keyword) async {
    await fetchArtisans(keyword: keyword, refresh: true);
  }

  /// 按分类筛选（客户端过滤）
  void filterByCategory(String category) {
    // 后端暂无分类筛选，客户端过滤
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _artisans = [];
    _currentArtisan = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

/// 手作人状态Provider
final artisanProvider = ChangeNotifierProvider<ArtisanProvider>((ref) {
  return ArtisanProvider();
});