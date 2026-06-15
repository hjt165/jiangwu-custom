import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 存储服务
/// 封装SharedPreferences，提供本地缓存功能

class StorageService {
  // 单例模式
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  /// 初始化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== 基础操作 ====================

  /// 存储字符串
  Future<bool> setString(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setString(key, value);
  }

  /// 获取字符串
  String getString(String key, {String defaultValue = ''}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  /// 存储整数
  Future<bool> setInt(String key, int value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setInt(key, value);
  }

  /// 获取整数
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  /// 存储布尔值
  Future<bool> setBool(String key, bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setBool(key, value);
  }

  /// 获取布尔值
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  /// 存储浮点数
  Future<bool> setDouble(String key, double value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setDouble(key, value);
  }

  /// 获取浮点数
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  /// 存储字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setStringList(key, value);
  }

  /// 获取字符串列表
  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }

  // ==================== JSON对象操作 ====================

  /// 存储JSON对象
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }

  /// 获取JSON对象
  Map<String, dynamic> getJson(String key, {Map<String, dynamic> defaultValue = const {}}) {
    final jsonString = getString(key);
    if (jsonString.isEmpty) return defaultValue;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return defaultValue;
    }
  }

  /// 存储JSON列表
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }

  /// 获取JSON列表
  List<Map<String, dynamic>> getJsonList(String key) {
    final jsonString = getString(key);
    if (jsonString.isEmpty) return [];
    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== 删除操作 ====================

  /// 删除指定键
  Future<bool> remove(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.remove(key);
  }

  /// 清除所有数据
  Future<bool> clear() async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.clear();
  }

  /// 是否包含指定键
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  /// 获取所有键
  Set<String> getKeys() {
    return _prefs?.getKeys() ?? {};
  }
}
