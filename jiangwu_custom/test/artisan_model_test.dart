import 'package:flutter_test/flutter_test.dart';
import 'package:jiangwu_custom/models/artisan.dart';

void main() {
  group('ArtisanStatus', () {
    test('has correct labels', () {
      expect(ArtisanStatus.pending.label, '待认证');
      expect(ArtisanStatus.verified.label, '已认证');
      expect(ArtisanStatus.rejected.label, '认证失败');
      expect(ArtisanStatus.suspended.label, '已封禁');
    });

    test('fromString matches by name', () {
      expect(ArtisanStatus.fromString('verified'), ArtisanStatus.verified);
      expect(ArtisanStatus.fromString('pending'), ArtisanStatus.pending);
    });

    test('fromString returns pending for unknown', () {
      expect(ArtisanStatus.fromString('unknown'), ArtisanStatus.pending);
    });
  });

  group('Artisan', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': '1',
        'userId': '100',
        'name': '匠心手作',
        'avatar': 'https://example.com/avatar.jpg',
        'description': '十年经验',
        'specialty': '皮具',
        'categories': ['皮具', '首饰'],
        'status': 'verified',
        'rating': 4.8,
        'ratingCount': 100,
        'orderCount': 50,
        'followerCount': 200,
        'workCount': 30,
        'certifications': ['金牌手作人'],
        'createdAt': '2026-01-01T00:00:00',
        'updatedAt': '2026-06-15T12:00:00',
      };
      final artisan = Artisan.fromJson(json);
      expect(artisan.id, '1');
      expect(artisan.name, '匠心手作');
      expect(artisan.status, ArtisanStatus.verified);
      expect(artisan.rating, 4.8);
      expect(artisan.categories.length, 2);
      expect(artisan.certifications.length, 1);
    });

    test('fromJson handles bio as description fallback', () {
      final json = {'id': '1', 'name': 'Test', 'bio': '手作简介'};
      final artisan = Artisan.fromJson(json);
      expect(artisan.description, '手作简介');
    });

    test('fromJson handles null/missing fields', () {
      final artisan = Artisan.fromJson({});
      expect(artisan.id, '');
      expect(artisan.name, '');
      expect(artisan.status, ArtisanStatus.pending);
      expect(artisan.rating, 0);
      expect(artisan.works, isEmpty);
    });

    test('isVerified returns true for verified status', () {
      final artisan = Artisan(
        id: '1',
        name: 'Test',
        status: ArtisanStatus.verified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(artisan.isVerified, true);
    });

    test('isVerified returns false for pending status', () {
      final artisan = Artisan(
        id: '1',
        name: 'Test',
        status: ArtisanStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(artisan.isVerified, false);
    });

    test('hasWorks returns true when works is not empty', () {
      final artisan = Artisan(
        id: '1',
        name: 'Test',
        works: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(artisan.hasWorks, false);
    });

    test('ratingText returns correct text', () {
      final highRating = Artisan(
        id: '1',
        name: 'Test',
        rating: 4.8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(highRating.ratingText, '金牌手作人');

      final midRating = Artisan(
        id: '2',
        name: 'Test',
        rating: 4.2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(midRating.ratingText, '优秀手作人');

      final lowRating = Artisan(
        id: '3',
        name: 'Test',
        rating: 3.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(lowRating.ratingText, '新手手作人');
    });

    test('certificationBadge returns first cert or empty', () {
      final withCerts = Artisan(
        id: '1',
        name: 'Test',
        certifications: const ['金牌'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(withCerts.certificationBadge, '金牌');

      final noCerts = Artisan(
        id: '2',
        name: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(noCerts.certificationBadge, '');
    });

    test('copyWith overrides specified fields', () {
      final artisan = Artisan(
        id: '1',
        name: 'Old',
        rating: 3.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final copied = artisan.copyWith(name: 'New', rating: 4.5);
      expect(copied.name, 'New');
      expect(copied.rating, 4.5);
      expect(copied.id, '1');
    });

    test('toJson roundtrip preserves data', () {
      final artisan = Artisan(
        id: '1',
        name: '测试手作人',
        specialty: '陶瓷',
        status: ArtisanStatus.verified,
        rating: 4.5,
        certifications: ['认证'],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 6, 15),
      );
      final json = artisan.toJson();
      final restored = Artisan.fromJson(json);
      expect(restored.id, artisan.id);
      expect(restored.name, artisan.name);
      expect(restored.specialty, artisan.specialty);
      expect(restored.status, artisan.status);
      expect(restored.rating, artisan.rating);
    });
  });
}
