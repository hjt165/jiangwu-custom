import 'package:flutter_test/flutter_test.dart';
import 'package:jiangwu_custom/models/product.dart';

void main() {
  group('ProductCategory', () {
    test('has correct labels', () {
      expect(ProductCategory.jewelry.label, '首饰');
      expect(ProductCategory.leather.label, '皮具');
      expect(ProductCategory.ceramic.label, '陶瓷');
      expect(ProductCategory.woodwork.label, '木艺');
      expect(ProductCategory.painting.label, '绘画');
      expect(ProductCategory.other.label, '其他');
    });

    test('fromString matches by name', () {
      expect(ProductCategory.fromString('jewelry'), ProductCategory.jewelry);
      expect(ProductCategory.fromString('ceramic'), ProductCategory.ceramic);
    });

    test('fromString returns other for unknown', () {
      expect(ProductCategory.fromString('unknown'), ProductCategory.other);
      expect(ProductCategory.fromString(''), ProductCategory.other);
    });
  });

  group('CraftParams', () {
    test('fromJson parses correctly', () {
      final json = {
        'difficulty': '简单',
        'estimatedDays': 3,
        'materialCost': 100.0,
        'laborCost': 200.0,
        'technique': '编织',
      };
      final params = CraftParams.fromJson(json);
      expect(params.difficulty, '简单');
      expect(params.estimatedDays, 3);
      expect(params.materialCost, 100.0);
      expect(params.laborCost, 200.0);
      expect(params.technique, '编织');
    });

    test('fromJson uses defaults for missing fields', () {
      final params = CraftParams.fromJson({});
      expect(params.difficulty, '中等');
      expect(params.estimatedDays, 7);
      expect(params.materialCost, 0);
      expect(params.laborCost, 0);
    });

    test('totalCost sums material and labor', () {
      final params = CraftParams(materialCost: 100, laborCost: 250);
      expect(params.totalCost, 350);
    });

    test('toJson roundtrip preserves data', () {
      const params = CraftParams(
        difficulty: '困难',
        estimatedDays: 14,
        materialCost: 500,
        laborCost: 800,
        technique: '雕刻',
      );
      final json = params.toJson();
      final restored = CraftParams.fromJson(json);
      expect(restored.difficulty, params.difficulty);
      expect(restored.estimatedDays, params.estimatedDays);
      expect(restored.materialCost, params.materialCost);
      expect(restored.laborCost, params.laborCost);
      expect(restored.technique, params.technique);
    });

    test('copyWith overrides specified fields', () {
      const original = CraftParams(difficulty: '简单', estimatedDays: 3);
      final copied = original.copyWith(difficulty: '困难');
      expect(copied.difficulty, '困难');
      expect(copied.estimatedDays, 3);
    });
  });

  group('Product', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': '1',
        'artisanId': '10',
        'title': '翡翠手镯',
        'description': '天然翡翠',
        'category': 'jewelry',
        'images': ['img1.jpg', 'img2.jpg'],
        'price': 1299.0,
        'originalPrice': 1599.0,
        'materials': ['翡翠', '银'],
        'tags': ['精品', '限量'],
        'viewCount': 100,
        'likeCount': 50,
        'orderCount': 10,
        'rating': 4.8,
        'isFeatured': true,
        'isAvailable': true,
      };
      final product = Product.fromJson(json);
      expect(product.id, '1');
      expect(product.title, '翡翠手镯');
      expect(product.category, ProductCategory.jewelry);
      expect(product.price, 1299.0);
      expect(product.images.length, 2);
      expect(product.materials.length, 2);
      expect(product.isFeatured, true);
    });

    test('fromJson handles null/missing fields', () {
      final product = Product.fromJson({});
      expect(product.id, '');
      expect(product.title, '');
      expect(product.category, ProductCategory.other);
      expect(product.price, 0);
      expect(product.images, isEmpty);
    });

    test('hasDiscount returns true when originalPrice > price', () {
      const product = Product(
        id: '1',
        title: 'Test',
        price: 100,
        originalPrice: 200,
      );
      expect(product.hasDiscount, true);
    });

    test('hasDiscount returns false when no originalPrice', () {
      const product = Product(id: '1', title: 'Test', price: 100);
      expect(product.hasDiscount, false);
    });

    test('discountPercent calculates correctly', () {
      const product = Product(
        id: '1',
        title: 'Test',
        price: 80,
        originalPrice: 100,
      );
      expect(product.discountPercent, 20);
    });

    test('discountPercent returns 0 when no discount', () {
      const product = Product(id: '1', title: 'Test', price: 100);
      expect(product.discountPercent, 0);
    });

    test('firstImage returns first image or empty', () {
      const product1 = Product(
        id: '1',
        title: 'Test',
        images: ['a.jpg', 'b.jpg'],
      );
      expect(product1.firstImage, 'a.jpg');

      const product2 = Product(id: '2', title: 'Test');
      expect(product2.firstImage, '');
    });

    test('copyWith overrides specified fields', () {
      const product = Product(id: '1', title: 'Old', price: 100);
      final copied = product.copyWith(title: 'New', price: 200);
      expect(copied.title, 'New');
      expect(copied.price, 200);
      expect(copied.id, '1');
    });

    test('toJson roundtrip preserves data', () {
      const product = Product(
        id: '1',
        artisanId: '10',
        title: '测试作品',
        category: ProductCategory.ceramic,
        price: 99.9,
        materials: ['瓷土'],
        tags: ['手工'],
      );
      final json = product.toJson();
      final restored = Product.fromJson(json);
      expect(restored.id, product.id);
      expect(restored.title, product.title);
      expect(restored.category, product.category);
      expect(restored.price, product.price);
      expect(restored.materials, product.materials);
    });
  });
}
