import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/artisan_service.dart';

/// 手作人收入统计状态管理
/// 使用ChangeNotifier实现

class ArtisanIncomeProvider extends ChangeNotifier {
  final ArtisanService _artisanService = ArtisanService();

  Map<String, dynamic> _stats = {
    'totalIncome': 0.0,
    'monthIncome': 0.0,
    'pendingIncome': 0.0,
    'withdrawnIncome': 0.0,
  };
  List<Map<String, dynamic>> _incomeRecords = [];
  List<Map<String, dynamic>> _withdrawRecords = [];
  bool _isLoading = false;
  String? _error;
  int _incomePage = 1;
  int _withdrawPage = 1;
  bool _hasMoreIncome = true;
  bool _hasMoreWithdraw = true;

  // Getters
  Map<String, dynamic> get stats => _stats;
  List<Map<String, dynamic>> get incomeRecords => _incomeRecords;
  List<Map<String, dynamic>> get withdrawRecords => _withdrawRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreIncome => _hasMoreIncome;
  bool get hasMoreWithdraw => _hasMoreWithdraw;

  /// 获取收入统计数据
  Future<void> fetchIncomeStats({String period = 'month'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await _artisanService.getIncomeStats(period: period);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取收入明细列表
  Future<void> fetchIncomeRecords({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _incomePage = 1;
      _incomeRecords = [];
      _hasMoreIncome = true;
    }

    if (!_hasMoreIncome) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRecords = await _artisanService.getIncomeRecords(page: _incomePage);

      if (refresh) {
        _incomeRecords = newRecords;
      } else {
        _incomeRecords = [..._incomeRecords, ...newRecords];
      }

      _hasMoreIncome = newRecords.length >= 20;
      _incomePage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取提现记录
  Future<void> fetchWithdrawRecords({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _withdrawPage = 1;
      _withdrawRecords = [];
      _hasMoreWithdraw = true;
    }

    if (!_hasMoreWithdraw) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newRecords = await _artisanService.getWithdrawRecords(page: _withdrawPage);

      if (refresh) {
        _withdrawRecords = newRecords;
      } else {
        _withdrawRecords = [..._withdrawRecords, ...newRecords];
      }

      _hasMoreWithdraw = newRecords.length >= 20;
      _withdrawPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 申请提现
  Future<bool> requestWithdraw({
    required double amount,
    required String accountType,
    required String accountInfo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _artisanService.requestWithdraw(
        amount: amount,
        accountType: accountType,
        accountInfo: accountInfo,
      );
      if (success) {
        // 刷新统计数据
        await fetchIncomeStats();
        await fetchWithdrawRecords(refresh: true);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
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
      'totalIncome': 0.0,
      'monthIncome': 0.0,
      'pendingIncome': 0.0,
      'withdrawnIncome': 0.0,
    };
    _incomeRecords = [];
    _withdrawRecords = [];
    _isLoading = false;
    _error = null;
    _incomePage = 1;
    _withdrawPage = 1;
    _hasMoreIncome = true;
    _hasMoreWithdraw = true;
    notifyListeners();
  }
}

/// 手作人收入统计Provider
final artisanIncomeProvider = ChangeNotifierProvider<ArtisanIncomeProvider>((ref) {
  return ArtisanIncomeProvider();
});
