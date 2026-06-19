import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/business/artisan_works_grid.dart';
import '../../widgets/business/filter_sort_sheet.dart';
import '../../widgets/common/loading_widget.dart';

/// 分类列表页
/// 展示特定分类下的作品列表，支持筛选排序

class CategoryScreen extends ConsumerStatefulWidget {
  final ProductCategory category;

  const CategoryScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  FilterSortOptions _filterOptions = const FilterSortOptions();
  List<Product> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(productProvider.notifier).fetchProducts(
        category: widget.category.name,
        refresh: true,
      );
      _applyFilter();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    final productState = ref.read(productProvider);
    setState(() {
      List<Product> products = List.from(productState.products);

      // 价格筛选
      products = products.where((product) {
        if (_filterOptions.minPrice != null &&
            product.price < _filterOptions.minPrice!) {
          return false;
        }
        if (_filterOptions.maxPrice != null &&
            product.price > _filterOptions.maxPrice!) {
          return false;
        }
        return true;
      }).toList();

      // 排序
      switch (_filterOptions.sortType) {
        case SortType.priceAsc:
          products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortType.priceDesc:
          products.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortType.sales:
          products.sort((a, b) => b.orderCount.compareTo(a.orderCount));
          break;
        case SortType.rating:
          products.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case SortType.newest:
          products.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
          break;
        case SortType.comprehensive:
          products.sort((a, b) {
            final scoreA = a.rating * 0.4 +
                a.orderCount * 0.3 +
                a.viewCount * 0.3;
            final scoreB = b.rating * 0.4 +
                b.orderCount * 0.3 +
                b.viewCount * 0.3;
            return scoreB.compareTo(scoreA);
          });
          break;
      }

      _products = products;
    });
  }

  void _showFilterSheet() {
    FilterSortSheet.show(
      context,
      currentOptions: _filterOptions,
      onConfirm: (options) {
        setState(() {
          _filterOptions = options;
        });
        _applyFilter();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.label),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingWidget())
                : ArtisanWorksGrid(
                    works: _products,
                    onWorkTap: (product) {
                      Navigator.of(context).pushNamed(
                        '/product/${product.id}',
                        arguments: product.id,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      color: AppColors.white,
      child: Row(
        children: [
          if (_filterOptions.minPrice != null || _filterOptions.maxPrice != null)
            Container(
              margin: const EdgeInsets.only(right: AppSizes.spacingSmall),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¥${_filterOptions.minPrice?.toStringAsFixed(0) ?? 0}~${_filterOptions.maxPrice?.toStringAsFixed(0) ?? "∞"}',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filterOptions = _filterOptions.copyWith(clearPrice: true);
                      });
                      _applyFilter();
                    },
                    child: const Icon(Icons.close, size: 14, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Text(
              '共${_products.length}件作品',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _filterOptions.sortType.label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}