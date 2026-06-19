import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address.dart';
import '../services/address_service.dart';

/// 地址状态
class AddressState {
  final List<Address> addresses;
  final bool isLoading;
  final String? error;

  AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.error,
  });

  AddressState copyWith({List<Address>? addresses, bool? isLoading, String? error}) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  Address? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}

/// 地址状态管理
class AddressNotifier extends StateNotifier<AddressState> {
  final AddressService _service = AddressService();

  AddressNotifier() : super(AddressState());

  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true);
    try {
      final addresses = await _service.getAddresses();
      state = state.copyWith(addresses: addresses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createAddress({
    required String name,
    required String phone,
    required String province,
    required String city,
    required String district,
    required String detail,
    bool isDefault = false,
  }) async {
    try {
      await _service.createAddress(
        name: name, phone: phone, province: province,
        city: city, district: district, detail: detail, isDefault: isDefault,
      );
      await loadAddresses();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateAddress({
    required int id,
    required String name,
    required String phone,
    required String province,
    required String city,
    required String district,
    required String detail,
    bool isDefault = false,
  }) async {
    try {
      await _service.updateAddress(
        id: id, name: name, phone: phone, province: province,
        city: city, district: district, detail: detail, isDefault: isDefault,
      );
      await loadAddresses();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await _service.deleteAddress(id);
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setDefault(int id) async {
    try {
      await _service.setDefault(id);
      await loadAddresses();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier();
});
