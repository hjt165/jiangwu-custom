import '../models/order.dart';
import '../models/product.dart';
import 'api_service.dart';

/// 手作人端API服务
/// 封装手作人相关接口调用

class ArtisanService {
  // 单例模式
  static final ArtisanService _instance = ArtisanService._internal();
  factory ArtisanService() => _instance;
  ArtisanService._internal();

  final ApiService _apiService = ApiService();

  // ==================== 工作台 ====================

  /// 获取工作台统计数据
  Future<Map<String, dynamic>> getWorkspaceStats() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/artisan/workspace/stats',
      );
      return response;
    } catch (e) {
      return {
        'pendingOrders': 0,
        'todayOrders': 0,
        'monthIncome': 0.0,
        'totalWorks': 0,
      };
    }
  }

  /// 获取待处理订单列表
  Future<List<Order>> getPendingOrders() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/artisan/orders/pending',
      );
      return response.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== 订单管理 ====================

  /// 获取手作人订单列表
  Future<List<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/artisan/orders',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (status != null) 'status': status.name,
        },
      );
      return response.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 接受订单
  Future<bool> acceptOrder(String orderId) async {
    try {
      await _apiService.post<void>('/artisan/orders/$orderId/accept');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 拒绝订单
  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    try {
      await _apiService.post<void>(
        '/artisan/orders/$orderId/reject',
        data: {'reason': reason},
      );
      return true;
    } catch (e) {
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
      await _apiService.post<void>(
        '/artisan/orders/$orderId/stages/$stageId/deliver',
        data: {
          'note': note,
          'images': images,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== 作品管理 ====================

  /// 获取手作人作品列表
  Future<List<Product>> getProducts({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/artisan/products',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return response.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 发布新作品
  Future<Product?> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/artisan/products',
        data: data,
      );
      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// 更新作品信息
  Future<bool> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _apiService.put<void>('/artisan/products/$productId', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 切换作品上下架状态
  Future<bool> toggleProductStatus(String productId) async {
    try {
      await _apiService.put<void>('/artisan/products/$productId/toggle-status');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 删除作品
  Future<bool> deleteProduct(String productId) async {
    try {
      await _apiService.delete<void>('/artisan/products/$productId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== 收入统计 ====================

  /// 获取收入统计数据
  Future<Map<String, dynamic>> getIncomeStats({String period = 'month'}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/artisan/income/stats',
        queryParameters: {'period': period},
      );
      return response;
    } catch (e) {
      return {
        'totalIncome': 0.0,
        'monthIncome': 0.0,
        'pendingIncome': 0.0,
        'withdrawnIncome': 0.0,
      };
    }
  }

  /// 获取收入明细列表
  Future<List<Map<String, dynamic>>> getIncomeRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/artisan/income/records',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// 获取提现记录
  Future<List<Map<String, dynamic>>> getWithdrawRecords({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/artisan/withdraw/records',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// 申请提现
  Future<bool> requestWithdraw({
    required double amount,
    required String accountType,
    required String accountInfo,
  }) async {
    try {
      await _apiService.post<void>(
        '/artisan/withdraw',
        data: {
          'amount': amount,
          'accountType': accountType,
          'accountInfo': accountInfo,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
