import '../models/address.dart';
import 'api_service.dart';

/// 收货地址服务
class AddressService {
  final _api = ApiService();

  Future<List<Address>> getAddresses() async {
    try {
      final data = await _api.get<List<dynamic>>('/address/list');
      return data.map((e) => Address.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Address?> getAddress(int id) async {
    try {
      final data = await _api.get<Map<String, dynamic>>('/address/$id');
      return Address.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<Address> createAddress({
    required String name,
    required String phone,
    required String province,
    required String city,
    required String district,
    required String detail,
    bool isDefault = false,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/address/create',
      data: {
        'name': name,
        'phone': phone,
        'province': province,
        'city': city,
        'district': district,
        'detail': detail,
        'isDefault': isDefault,
      },
    );
    return Address.fromJson(data);
  }

  Future<Address> updateAddress({
    required int id,
    required String name,
    required String phone,
    required String province,
    required String city,
    required String district,
    required String detail,
    bool isDefault = false,
  }) async {
    final data = await _api.put<Map<String, dynamic>>(
      '/address/$id',
      data: {
        'name': name,
        'phone': phone,
        'province': province,
        'city': city,
        'district': district,
        'detail': detail,
        'isDefault': isDefault,
      },
    );
    return Address.fromJson(data);
  }

  Future<void> deleteAddress(int id) async {
    await _api.delete('/address/$id');
  }

  Future<void> setDefault(int id) async {
    await _api.put('/address/$id/default');
  }
}
