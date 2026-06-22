import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/loading_widget.dart';

/// 发现页主页面
/// 分类浏览、搜索、手作人主页入口

class DiscoverScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const DiscoverScreen({super.key, this.showAppBar = false});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  ProductCategory? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(productProvider.notifier).fetchProducts(
        category: _selectedCategory?.name,
        refresh: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    final productState = ref.read(productProvider);
    if (productState.isLoading || !productState.hasMore) return;
    await ref.read(productProvider.notifier).fetchProducts(
      category: _selectedCategory?.name,
    );
  }

  void _onCategorySelected(ProductCategory? category) {
    setState(() => _selectedCategory = category);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('发现'),
            )
          : null,
      body: RepaintBoundary(
        child: Column(
          children: [
            _buildSearchBar(context),
            _buildCategoryTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingWidget())
                  : productState.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                              const SizedBox(height: AppSizes.spacingMedium),
                              Text('加载失败: ${productState.error}', style: const TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: AppSizes.spacingMedium),
                              TextButton(
                                onPressed: _loadProducts,
                                child: const Text('重试'),
                              ),
                            ],
                          ),
                        )
                      : _buildProductGrid(productState.products),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.search);
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Row(
            children: [
              SizedBox(width: AppSizes.paddingMedium),
              Icon(Icons.search, color: AppColors.textHint),
              SizedBox(width: AppSizes.spacingSmall),
              Text(
                '搜索手作作品、手作人...',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'label': '全部', 'category': null},
      {'label': '首饰', 'category': ProductCategory.jewelry},
      {'label': '皮具', 'category': ProductCategory.leather},
      {'label': '陶瓷', 'category': ProductCategory.ceramic},
      {'label': '木艺', 'category': ProductCategory.woodwork},
      {'label': '绘画', 'category': ProductCategory.painting},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['category'];
          return Container(
            margin: const EdgeInsets.only(right: AppSizes.spacingSmall),
            child: ChoiceChip(
              label: Text(cat['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                _onCategorySelected(cat['category'] as ProductCategory?);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 60, color: AppColors.textHint),
            SizedBox(height: AppSizes.spacingMedium),
            Text('暂无作品', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(productProvider.notifier).fetchProducts(
          category: _selectedCategory?.name,
          refresh: true,
        );
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.spacingMedium,
            crossAxisSpacing: AppSizes.spacingMedium,
            childAspectRatio: 0.8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/product/${product.id}',
          arguments: product.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: AppSizes.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusMedium),
                  ),
                ),
                child: product.coverImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusMedium),
                        ),
                        child: Image.network(
                          product.coverImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.image_outlined, size: 40, color: AppColors.textHint),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined, size: 40, color: AppColors.textHint),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.spacingXSmall),
                        Text(
                          '¥${product.price.toStringAsFixed(0)}起',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}