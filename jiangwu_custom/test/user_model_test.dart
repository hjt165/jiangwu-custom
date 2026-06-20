import 'package:flutter_test/flutter_test.dart';
import 'package:jiangwu_custom/models/user.dart';

void main() {
  group('User', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 42,
        'phone': '13800000000',
        'nickname': '测试用户',
        'avatar': 'https://example.com/avatar.jpg',
        'token': 'jwt_token_123',
        'createdAt': '2026-01-15T10:30:00',
        'updatedAt': '2026-06-20T12:00:00',
      };
      final user = User.fromJson(json);
      expect(user.id, '42');
      expect(user.phone, '13800000000');
      expect(user.nickname, '测试用户');
      expect(user.avatar, 'https://example.com/avatar.jpg');
      expect(user.token, 'jwt_token_123');
      expect(user.createdAt, isNotNull);
      expect(user.createdAt!.year, 2026);
    });

    test('fromJson converts int id to string', () {
      final json = {'id': 123, 'phone': '13800000001'};
      final user = User.fromJson(json);
      expect(user.id, '123');
    });

    test('fromJson handles null/missing fields', () {
      final user = User.fromJson({});
      expect(user.id, '');
      expect(user.phone, '');
      expect(user.nickname, isNull);
      expect(user.avatar, isNull);
      expect(user.token, isNull);
      expect(user.createdAt, isNull);
    });

    test('isLoggedIn returns true when token exists', () {
      const user = User(id: '1', phone: '138', token: 'abc');
      expect(user.isLoggedIn, true);
    });

    test('isLoggedIn returns false when token is null', () {
      const user = User(id: '1', phone: '138');
      expect(user.isLoggedIn, false);
    });

    test('isLoggedIn returns false when token is empty', () {
      const user = User(id: '1', phone: '138', token: '');
      expect(user.isLoggedIn, false);
    });

    test('copyWith overrides specified fields', () {
      const user = User(id: '1', phone: '138', nickname: 'Old');
      final copied = user.copyWith(nickname: 'New');
      expect(copied.nickname, 'New');
      expect(copied.phone, '138');
      expect(copied.id, '1');
    });

    test('toJson roundtrip preserves data', () {
      const user = User(
        id: '1',
        phone: '13800000000',
        nickname: '测试',
        token: 'jwt_token',
      );
      final json = user.toJson();
      final restored = User.fromJson(json);
      expect(restored.id, user.id);
      expect(restored.phone, user.phone);
      expect(restored.nickname, user.nickname);
      expect(restored.token, user.token);
    });

    test('toJson includes null fields as null', () {
      const user = User(id: '1', phone: '138');
      final json = user.toJson();
      expect(json['nickname'], isNull);
      expect(json['avatar'], isNull);
      expect(json['token'], isNull);
    });
  });
}
