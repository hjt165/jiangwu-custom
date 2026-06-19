/// 收货地址模型
class Address {
  final int id;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final bool isDefault;
  final String? createdAt;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    this.isDefault = false,
    this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      detail: json['detail'] ?? '',
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'province': province,
    'city': city,
    'district': district,
    'detail': detail,
    'isDefault': isDefault,
  };

  String get fullAddress => '$province$city$district$detail';
}
