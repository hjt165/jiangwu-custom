import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customization.dart';
import '../models/product.dart';

/// 定制状态管理
/// 管理定制参数、3D预览数据

class CustomizationProvider extends ChangeNotifier {
  Customization? _currentCustomization;
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  // 定制参数
  String _material = '';
  String _size = '';
  String _color = '';
  String _engraving = '';
  String _description = '';
  List<String> _referenceImages = [];
  Map<String, dynamic> _additionalParams = {};

  // Getters
  Customization? get currentCustomization => _currentCustomization;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get material => _material;
  String get size => _size;
  String get color => _color;
  String get engraving => _engraving;
  String get description => _description;
  List<String> get referenceImages => _referenceImages;
  Map<String, dynamic> get additionalParams => _additionalParams;

  /// 选择作品
  void selectProduct(Product product) {
    _selectedProduct = product;
    notifyListeners();
  }

  /// 设置材质
  void setMaterial(String material) {
    _material = material;
    notifyListeners();
  }

  /// 设置尺寸
  void setSize(String size) {
    _size = size;
    notifyListeners();
  }

  /// 设置颜色
  void setColor(String color) {
    _color = color;
    notifyListeners();
  }

  /// 设置雕刻内容
  void setEngraving(String engraving) {
    _engraving = engraving;
    notifyListeners();
  }

  /// 设置描述
  void setDescription(String description) {
    _description = description;
    notifyListeners();
  }

  /// 添加参考图片
  void addReferenceImage(String imagePath) {
    if (!_referenceImages.contains(imagePath)) {
      _referenceImages = [..._referenceImages, imagePath];
      notifyListeners();
    }
  }

  /// 移除参考图片
  void removeReferenceImage(String imagePath) {
    _referenceImages = _referenceImages.where((p) => p != imagePath).toList();
    notifyListeners();
  }

  /// 清空参考图片
  void clearReferenceImages() {
    _referenceImages = [];
    notifyListeners();
  }

  /// 设置附加参数
  void setAdditionalParam(String key, dynamic value) {
    _additionalParams = {..._additionalParams, key: value};
    notifyListeners();
  }

  /// 获取参数摘要
  String get summary {
    final parts = <String>[];
    if (_material.isNotEmpty) parts.add('材质：$_material');
    if (_size.isNotEmpty) parts.add('尺寸：$_size');
    if (_color.isNotEmpty) parts.add('颜色：$_color');
    if (_engraving.isNotEmpty) parts.add('雕刻：$_engraving');
    return parts.join(' | ');
  }

  /// 是否有效（至少填写了一项参数）
  bool get isValid {
    return _material.isNotEmpty ||
        _size.isNotEmpty ||
        _color.isNotEmpty ||
        _engraving.isNotEmpty;
  }

  /// 构建Customization对象
  Customization buildCustomization() {
    final now = DateTime.now();
    return Customization(
      id: '',
      productId: _selectedProduct?.id ?? '',
      material: _material,
      size: _size,
      color: _color,
      engraving: _engraving,
      description: _description,
      referenceImages: _referenceImages,
      additionalParams: _additionalParams,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 重置所有参数
  void reset() {
    _currentCustomization = null;
    _selectedProduct = null;
    _material = '';
    _size = '';
    _color = '';
    _engraving = '';
    _description = '';
    _referenceImages = [];
    _additionalParams = {};
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 定制状态Provider
final customizationProvider = ChangeNotifierProvider<CustomizationProvider>((ref) {
  return CustomizationProvider();
});
